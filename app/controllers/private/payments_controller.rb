# frozen_string_literal: true
module Private
  class PaymentsController < PrivateController
    before_action :check_existence, only: :create

    def create
      return open_customer_portal if current_project.paid_plan?

      session =
        Stripe::Checkout::Session.create(
          customer: stripe_customer,
          payment_method_types: ['card'],
            line_items: [{ price: ENV.fetch('STRIPE_PRICE_ID'), quantity: 1},
          ],
          metadata: { project_id: current_project.uuid, project_name: current_project.name },
          mode: 'subscription',
          success_url:
            "#{success_project_payments_url(current_project)}?session_id={CHECKOUT_SESSION_ID}",
          cancel_url: cancel_project_payments_url(current_project),
        )

      redirect_to session.url, allow_other_host: true
    end

    def open_customer_portal
      session =
        Stripe::BillingPortal::Session.create(
          { customer: stripe_customer, return_url: project_settings_url(current_project) },
        )

      redirect_to session.url, allow_other_host: true
    end

    def success
      session_id = params[:session_id]
      retrieve_and_save_info(session_id) if session_id.present?
      #handle successful payments
      redirect_to project_settings_path(current_project), notice: 'Purchase Successful'
    end

    def cancel
      #handle if the payment is cancelled
      redirect_to project_settings_path(current_project)
    end

    # def webhook
    #     # Replace this endpoint secret with your endpoint's unique secret
    #     # If you are testing with the CLI, find the secret by running 'stripe listen'
    #     # If you are using an endpoint defined with the API or dashboard, look in your webhook settings
    #     # at https://dashboard.stripe.com/webhooks
    #     webhook_secret = 'whsec_12345'
    #     payload = request.body.read
    #     if !webhook_secret.empty?
    #       # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
    #       sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    #       event = nil
    #
    #       begin
    #         event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
    #       rescue JSON::ParserError => e
    #         status 400
    #         return
    #       rescue Stripe::SignatureVerificationError => e
    #         puts '⚠️  Webhook signature verification failed.'
    #         status 400
    #         return
    #       end
    #     else
    #       data = JSON.parse(payload, symbolize_names: true)
    #       event = Stripe::Event.construct_from(data)
    #     end
    #     # Get the type of webhook event sent - used to check the status of PaymentIntents.
    #     event_type = event['type']
    #     data = event['data']
    #     data_object = data['object']
    #
    #     if event_type == 'customer.subscription.deleted'
    #       puts "Subscription canceled: #{event.id}"
    #     end
    #
    #     if event_type == 'customer.subscription.updated'
    #       puts "Subscription updated: #{event.id}"
    #     end
    #
    #     if event_type == 'customer.subscription.created'
    #       puts "Subscription created: #{event.id}"
    #     end
    #
    #     if event_type == 'customer.subscription.trial_will_end'
    #       puts "Subscription trial will end: #{event.id}"
    #     end
    # end

    private

    def check_existence
      return if stripe_customer.present? && !stripe_customer['deleted']

      # flash[:notice] = 'Error while creating customer. Please try again later'
      redirect_to project_settings_path(current_project),
                  notice: 'Error while creating subscription. Please try again later'
    end

    def retrieve_and_save_info(session_id)
      session = Stripe::Checkout::Session.retrieve(session_id)
      return if session.status != 'complete'

      subscription = Stripe::Subscription.retrieve(session.subscription)
      current_project.track!(source: 'Stripe Payment', author: current_user) do
        current_project.update!(
          stripe_attributes: {
            subscription_attributes: {
              id: subscription.id,
              status: subscription.status,
              latest_invoice: subscription.latest_invoice,
              cancel_at: subscription.cancel_at,
              canceled_at: subscription.canceled_at,
              start_date: subscription.start_date,
            }
          }
        )
      end
    end

    def stripe_customer
      return @stripe_customer if @stripe_customer.present?

      if current_project.stripe&.customer_id.present?
        @stripe_customer = Stripe::Customer.retrieve(current_project.stripe.customer_id)
        return @stripe_customer
      end

      description = "Project #{current_project.uuid}"
      @stripe_customer = Stripe::Customer.create({ email: current_user.email, description: })
      current_project.track!(source: 'Create Stripe Customer', author: current_user) do
        current_project.update!(stripe_attributes: { customer_id: @stripe_customer.id })
      end
      @stripe_customer
    end
  end
end
