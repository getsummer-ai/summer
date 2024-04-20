# frozen_string_literal: true
module Private
  class PaymentsController < PrivateController
    before_action :check_existence, only: :create

    def create
      session =
        stripe_service.create_session(
          success_url: success_project_payments_url(current_project),
          cancel_url: cancel_project_payments_url(current_project),
          return_url: return_project_payments_url(current_project),
        )
      redirect_to session.url, allow_other_host: true
    end

    def success
      sess_id = params[:session_id]
      res = sess_id.present? ? stripe_service.session_success_callback(sess_id) : false

      redirect_to project_settings_path(current_project), notice: res ? 'Purchase Successful' : ''
    end

    def cancel
      redirect_to project_settings_path(current_project)
    end

    def return
      subscription_info = current_project.stripe.subscription.id
      stripe_service.update_subscription_info(subscription_info) if subscription_info.present?
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
      return unless stripe_service.stripe_customer['deleted']

      redirect_to project_settings_path(current_project),
                  notice: 'Error while creating subscription. Please try again later'
    end

    def stripe_service
      @stripe_service ||= ProjectStripeService.new(current_project, user: current_user)
    end
  end
end
