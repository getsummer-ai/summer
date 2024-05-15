# frozen_string_literal: true
module Private
  class PaymentsController < PrivateController
    before_action :check_existence, only: :create

    IS_PLAYGROUND = ENV.fetch('PLAYGROUND_MODE', nil) == 'true'

    def create(stripe_session = nil)
      session =
        stripe_session.presence ||
          stripe_service.create_checkout_session(
            success_url: success_project_payments_url(current_project),
            cancel_url: cancel_project_payments_url(current_project),
            plan_id: find_plan,
          )

      redirect_to session.url, allow_other_host: true
    rescue StandardError => e
      Rails.logger.error e.message
      Sentry.capture_exception e
      redirect_to project_settings_path(current_project),
                  notice: 'Error happened while creating subscription'
    end

    def subscription
      return create if current_project.free_plan?

      session = stripe_service.create_custom_portal_session(return_project_payments_url(current_project))
      create(session)
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

    def admin_delete_subscription
      if IS_PLAYGROUND
        if current_project.stripe.customer_id.present?
          Stripe::Customer.delete(current_project.stripe.customer_id)
        end
        current_project.update!(
          plan: 'free',
          status: 'active',
          stripe_attributes: {
            customer_id: nil,
            subscription_attributes: {
              id: nil,
              status: nil,
              cancel_at: nil,
              start_date: nil,
              canceled_at: nil,
              latest_invoice: nil,
              plan_id: nil,
              plan_interval: nil
            },
          },
        )
      end
      redirect_to project_settings_path(current_project)
    end

    def admin_suspend_project
      current_project.update!(plan: 'free', status: 'suspended') if IS_PLAYGROUND
      redirect_to project_settings_path(current_project)
    end

    private

    def find_plan
      permitted_attributes = %i[plan period]
      plan, period =
        params.require(:subscription).permit(permitted_attributes).values_at(*permitted_attributes)
      ProjectStripeService.plans.dig(IS_PLAYGROUND ? :test : :live, plan&.to_sym, period&.to_sym)
    end

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
