# frozen_string_literal: true
#
# @!attribute project
#  @return [Project]
# @!attribute user
#  @return [User]
# @!attribute return_url
#  @return [String]
class ProjectStripeService
  attr_reader :project, :user, :return_url

  # @param project [Project]
  # @param user [User]
  def initialize(project, user:)
    # @type [Project]
    @project = project
    # @type [User]
    @user = user
  end

  # @param success_url [String]
  # @param cancel_url [String]
  # @param return_url [String]
  # @return [Stripe::Checkout::Session]
  def create_session(success_url:, cancel_url:, return_url:)
    return create_custom_portal_session(return_url) if project.paid_plan? || project.stripe&.subscription&.id.present?

    Stripe::Checkout::Session.create(
      customer: stripe_customer,
      payment_method_types: ['card'],
      line_items: [{ price: ENV.fetch('STRIPE_PRICE_ID'), quantity: 1 }],
      metadata: {
        project_id: project.uuid,
        project_name: project.name,
      },
      mode: 'subscription',
      success_url: "#{success_url}?session_id={CHECKOUT_SESSION_ID}",
      cancel_url:
    )
  end

  def session_success_callback(session_id)
    session = Stripe::Checkout::Session.retrieve(session_id)
    return false if session.status != 'complete'

    project.track!(source: 'Stripe Success Callback', author: user) do
      update_subscription_info(session.subscription)
    end
    true
  end

  def stripe_customer
    return @stripe_customer if @stripe_customer.present?

    if project.stripe&.customer_id.present?
      return (@stripe_customer = Stripe::Customer.retrieve(project.stripe.customer_id))
    end

    project.track!(source: 'New Stripe Customer', author: user) do
      description = "Project #{project.uuid}"
      @stripe_customer = Stripe::Customer.create({ email: user.email, description: })
      project.update!(stripe_attributes: { customer_id: @stripe_customer.id })
    end
    @stripe_customer
  end

  def update_subscription_info(subscription_id)
    subscription = Stripe::Subscription.retrieve(subscription_id)
    plan = subscription.status == 'active' ? 'paid' : 'free'
    subscription_attributes = useful_subscription_attributes(subscription)
    project.update!(plan:, stripe_attributes: { subscription_attributes: })

    ProjectSuspensionService.new(project).actualize_status
  end

  private

  def create_custom_portal_session(return_url)
    Stripe::BillingPortal::Session.create({ customer: stripe_customer, return_url: })
  end

  # @param [Stripe::Subscription] subscription
  def useful_subscription_attributes(subscription)
    {
      id: subscription.id,
      status: subscription.status,
      latest_invoice: subscription.latest_invoice,
      cancel_at: subscription.cancel_at,
      canceled_at: subscription.canceled_at,
      start_date: subscription.start_date,
    }
  end
end
