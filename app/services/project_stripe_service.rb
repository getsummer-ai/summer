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
    plan = find_plan(stripe_subscription.plan)

    ProjectSubscription.transaction do
      subscription = plan.present? ? find_or_create_subscription!(stripe_subscription, plan) : nil
      project.track!(source: 'Stripe Update Subscription Info', author: user) do
        project.update!(
          plan: plan.nil? ? 'enterprise' : plan.name.to_s,
          subscription:,
          stripe_attributes: {
            subscription_attributes: useful_subscription_attributes(stripe_subscription),
          },
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

  # @param [Stripe::Subscription] stripe_sub
  # @param [ProjectStripeService::Plan] plan
  # @return [ProjectSubscription]
  def find_or_create_subscription!(stripe_sub, plan)
    sub =
      project
        .subscriptions
        .find_or_initialize_by(start_at: Time.at(stripe_sub.current_period_start).utc) do |s|
          s.summarize_usage = 0
        end
    source = "Project Subscription #{sub.new_record? ? 'Create' : 'Update'}"
    cancel_at = stripe_sub.cancel_at || stripe_sub.ended_at

    sub.track!(source:, author: user) do
      sub.update!(
        plan: plan.name,
        stripe: stripe_sub.as_json,
        summarize_limit: plan.summarize_limit,
        end_at: Time.at(stripe_sub.current_period_end).utc,
        cancel_at: cancel_at.present? ? Time.at(cancel_at).utc : nil,
      )
    end

    sub
  end

  # @param [Stripe::Plan] plan
  # @return [ProjectStripeService::Plan, nil]
  def find_plan(plan)
    plan_info = ProjectStripeService::Plan.find_by_stripe_plan(plan)
    return plan_info if plan_info.present?

    Sentry.capture_message("Can't find a plan", extra: { project_id: project.id, plan_id: plan.id })
    Rails.logger.error("Can't find a plan #{plan.id} for project #{project.id}")
    nil
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
      ended_at: subscription.ended_at,
      canceled_at: subscription.canceled_at,
      start_date: subscription.start_date,
    }
  end
end
