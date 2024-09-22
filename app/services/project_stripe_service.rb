# frozen_string_literal: true
#
# @!attribute project
#  @return [Project]
# @!attribute user
#  @return [User, nil]
# @!attribute return_url
#  @return [String]
class ProjectStripeService
  attr_reader :project, :user, :return_url

  # @param project [Project]
  # @param user [User, nil]
  def initialize(project, user: nil)
    # @type [Project]
    @project = project
    # @type [User]
    @user = user
  end

  # There is a problem with subscription logic which I'm not going to solve right now.
  #
  # The problem is following:
  #
  # When a user changes interval of subscription from month to year or vice versa -
  # a new project_subscription row is created so the limit of usage is reset.
  #
  # Foe example.
  # Somebody paid 90$ for 60_000 clicks per year. He had spent 60_000 clicks in first month and decided to
  # change Stripe interval to the monthly. -> He will have 5_000 clicks per month and will be paying
  # nothing for the next 11 months.
  # If the user reaches the limit of 5_000 clicks in the first month,
  # his project will be suspended, and the user will be able to change interval to yearly again,
  # and he will get 60_000 clicks for the next 12 months again. In total he will pay only 90$ + (90/12)$
  # 
  PLAN_LIMITS = { light: 5_000, pro: 25_000 }.freeze

  PLANS = {
    test: {
      light: {
        year: 'price_1PBXGeDm8NzUNvXDPM4V1dha',
        month: 'price_1PBXHIDm8NzUNvXDFmCw828n',
      },
      pro: {
        year: 'price_1PBXI6Dm8NzUNvXDk0FfLVtH',
        month: 'price_1PBXORDm8NzUNvXDoV7gv6Zi',
      },
    },
    live: {
      light: {
        year: 'price_1PFK07Dm8NzUNvXDBJER9D7s',
        month: 'price_1PFJzGDm8NzUNvXDrUfab0EI',
      },
      pro: {
        year: 'price_1PFK16Dm8NzUNvXDZcLnQSWa',
        month: 'price_1PFK0dDm8NzUNvXDsMXEPJ9s',
      },
    },
  }.freeze

  # It is called after the successful payment. Updates info if webhook has not updated the info yet
  #
  # @param session_id [String]
  def session_success_callback(session_id)
    session = Stripe::Checkout::Session.retrieve(session_id)
    return false if session.status != 'complete' || session.metadata&.project_id != @project.uuid

    update_subscription_info(session.subscription)
    true
  end

  def stripe_customer
    return @stripe_customer if @stripe_customer.present?

    if project.stripe&.customer_id.present?
      return(@stripe_customer = Stripe::Customer.retrieve(project.stripe.customer_id))
    end

    project.track!(source: 'New Stripe Customer', author: user) do
      description = "Project #{project.uuid}"
      @stripe_customer = Stripe::Customer.create({ email: user.email, description: })
      project.update!(stripe_attributes: { customer_id: @stripe_customer.id })
    end
    @stripe_customer
  end

  def update_subscription_info(subscription_id)
    stripe_subscription = Stripe::Subscription.retrieve(subscription_id)
    plan = find_plan_name(stripe_subscription.plan)

    ProjectSubscription.transaction do
      subscription = nil
      subscription = find_or_create_subscription!(stripe_subscription, plan) if plan.present?
      stripe_attributes = {
        subscription_attributes: useful_subscription_attributes(stripe_subscription),
      }
      project.track!(source: 'Stripe Update Subscription Info', author: user) do
        project.update!(
          plan: plan.nil? && project.enterprise_plan? ? 'enterprise' : plan,
          subscription:,
          stripe_attributes:,
        )
      end
    end

    ProjectSuspensionService.new(project).actualize_status
  end

  def create_custom_portal_session(return_url)
    Stripe::BillingPortal::Session.create({ customer: stripe_customer, return_url: })
  end

  def create_checkout_session(success_url:, cancel_url:, plan_id:)
    Stripe::Checkout::Session.create(
      customer: stripe_customer,
      payment_method_types: ['card'],
      line_items: [{ price: plan_id, quantity: 1 }],
      metadata: {
        project_id: project.uuid,
        project_name: project.name,
      },
      mode: 'subscription',
      success_url: "#{success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url:,
    )
  end

  private

  # @param stripe_subscription [Stripe::Subscription]
  # @param plan [Symbol]
  # @return [ProjectSubscription]
  def find_or_create_subscription!(stripe_subscription, plan)
    start_at = Time.at(stripe_subscription.current_period_start).utc
    end_at = Time.at(stripe_subscription.current_period_end).utc
    project_subscription =
      project.subscriptions.find_or_initialize_by(start_at:, end_at:) { |s| s.summarize_usage = 0 }

    project_subscription.track!(
      source: "Project Subscription #{project_subscription.new_record? ? 'Create' : 'Update'}",
      author: user,
    ) do
      project_subscription.update!(
        plan:,
        stripe: stripe_subscription.as_json,
        summarize_limit: find_summarize_limit(plan, start_at, end_at),
        cancel_at:
          stripe_subscription.cancel_at.present? ? Time.at(stripe_subscription.cancel_at).utc : nil,
      )
    end

    project_subscription
  end

  # @param [Stripe::Plan] plan
  def find_plan_name(plan)
    current_env_plans = PLANS[plan.livemode == true ? :live : :test]
    interval = plan.interval.to_sym
    res = nil
    res = :light if current_env_plans.dig(:light, interval) == plan.id
    res = :pro if current_env_plans.dig(:pro, interval) == plan.id
    return res if res.present?

    Sentry.capture_message("Can't find a plan", extra: { project_id: project.id, plan_id: plan.id })
    Rails.logger.error("Can't find a plan #{plan.id} for project #{project.id}")
    nil
  end

  # @param [Symbol] plan
  # @param [Time] start_at
  # @param [Time] end_at
  # @return [Integer]
  def find_summarize_limit(plan, start_at, end_at)
    months = ((end_at - start_at) / 1.month).round
    res = (PLAN_LIMITS[plan] * months).to_i
    if months != 1 && months != 12
      Sentry.capture_message('Wrong summarize limit', extra: { project_id: project.id, plan:, months: })
      Rails.logger.error("Wrong summarize limit for project #{project.id} plan #{plan} months #{months}")
    end
    res
  end

  # @param [Stripe::Subscription] subscription
  def useful_subscription_attributes(subscription)
    {
      id: subscription.id,
      status: subscription.status,
      latest_invoice: subscription.latest_invoice,
      plan_id: subscription.plan.id,
      plan_interval: subscription.plan.interval,
      cancel_at: subscription.cancel_at,
      canceled_at: subscription.canceled_at,
      start_date: subscription.start_date,
    }
  end
end
