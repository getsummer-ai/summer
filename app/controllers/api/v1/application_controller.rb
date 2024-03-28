# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with common logic for user API
    #
    class ApplicationController < ActionController::API
      before_action :validate_api_key
      before_action :validate_origin
      helper_method :current_project

      wrap_parameters false

      respond_to :json

      private

      # @return [Project]
      def current_project
        @current_project ||= Project.find_by(uuid: api_key)
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
    end
  end
end
