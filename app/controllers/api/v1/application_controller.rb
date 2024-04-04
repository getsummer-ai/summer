# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with common logic for user API
    #
    class ApplicationController < ActionController::API
      include Pundit::Authorization

      rescue_from Pundit::NotAuthorizedError, with: :pundit_request_not_authorized

      before_action :validate_api_key
      before_action :validate_origin
      before_action { |_| authorize current_project, :use_button? }
      helper_method :current_project
      wrap_parameters false
      respond_to :json

      def policy_scope(scope)
        super([:api, scope])
      end

      def authorize(record, query = nil)
        super([:api, record], query)
      end

      private

      def current_user
      end

      # @return [Project]
      def current_project
        @current_project ||= Project.available.find_by(uuid: api_key)
      end

      def validate_api_key
        return if api_key.present? && current_project.present?
        render json: { message: 'Invalid Api-Key' }, status: :forbidden
      end

      def api_key
        @api_key ||=
          request.headers[:HTTP_API_KEY].presence ||
            params.extract!(:key).permit(:key)[:key].presence
      end

      def validate_origin
        form = CheckProjectRequestForm.new(current_project, request.origin, request.referer)
        send_incorrect_domain_response! if form.invalid?
      end

      def send_incorrect_domain_response!
        render json: { code: :wrong_domain, message: 'Incorrect domain' }, status: :forbidden
      end

      def pundit_request_not_authorized(exception)
        policy = exception.policy
        message = (policy.error_message.presence || exception.message).to_s
        # exception.query.to_s.humanize
        render json: { code: policy.class.to_s.underscore, message: }, status: :forbidden
      end
    end
  end
end
