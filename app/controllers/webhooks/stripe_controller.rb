# frozen_string_literal: true

module Webhooks
  # @!attribute event
  #  @return [Stripe::StripeObject]
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!
    skip_before_action :update_user_locale!

    attr_reader :event
    respond_to :json

    WEBHOOK_SECRET = ENV.fetch('STRIPE_WEBHOOK_SECRET', nil)

    if WEBHOOK_SECRET.present?
      before_action :check_signed_webhook
    else
      before_action :check_webhook
    end

    before_action :check_event_type

    def webhook
      event_type = event['type']
      data = event['data']
      begin
        subscription = data['object']
        stripe_customer = subscription&.customer
        raise "Stripe webhook #{event_type} does not contain customer" if stripe_customer.blank?

        project = Project.find_by("stripe->>'customer_id' = ?", stripe_customer)
        raise "Stripe webhook #{event_type}. Customer not found #{stripe_customer}" if project.nil?

        ProjectStripeService.new(project).update_subscription_info(subscription.id)
      rescue StandardError => e
        Sentry.capture_exception(e, extra: data)
        Rails.logger.error(e.message)
      ensure
        head :ok
      end
    end

    private

    def check_signed_webhook
      # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      @event = nil

      begin
        @event = Stripe::Webhook.construct_event(request.body.read, sig_header, WEBHOOK_SECRET)
      rescue JSON::ParserError
        status 400
      rescue Stripe::SignatureVerificationError => e
        Sentry.capture_exception(e)
        Rails.logger.info '⚠️  Webhook signature verification failed.'
        status 400
      end
    end

    def check_webhook
      payload = request.body.read
      return head :bad_request if payload.blank?

      data = JSON.parse(payload, symbolize_names: true)
      @event = Stripe::Event.construct_from(data)
    rescue JSON::ParserError
      head :bad_request
    end

    def check_event_type
      return if %w[customer.subscription.updated customer.subscription.deleted].include? event['type']

      head(:ok)
    end
  end
end
