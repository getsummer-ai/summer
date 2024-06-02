# frozen_string_literal: true
module Private
  class PaymentsController < PrivateController
    before_action :check_existence, only: :create

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

    #
    # Stripe Webhook catcher performs the same action when subscription is created
    # so this method is used to update subscription info in case webhook is not working
    #
    def success
      sess_id = params[:session_id]
      res = sess_id.present? ? stripe_service.session_success_callback(sess_id) : false

      redirect_to project_settings_path(current_project), notice: res ? 'Purchase Successful' : ''
    end

    def cancel
      redirect_to project_settings_path(current_project)
    end

    def return
      # We don't need to update subscription info here
      # because it will be updated by webhook. Just redirect to settings
      #
      # subscription_info = current_project.stripe.subscription.id
      # stripe_service.update_subscription_info(subscription_info) if subscription_info.present?
      #
      redirect_to project_settings_path(current_project)
    end

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
      ProjectStripeService::PLANS.dig(IS_PLAYGROUND ? :test : :live, plan&.to_sym, period&.to_sym)
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
