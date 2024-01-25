# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with common logic for user API
    #
    class ApplicationController < ActionController::API
      before_action :validate_api_token
      before_action :validate_origin

      helper_method :current_project

      respond_to :json

      private

      # @return [Project]
      def current_project
        @current_project ||= Project.find_by(id: request.headers[:HTTP_API_TOKEN])
      end

      def validate_api_token
        return if request.headers[:HTTP_API_TOKEN].present? && current_project.present?
        render json: { message: 'Invalid api_token' }, status: :forbidden
      end

      def validate_origin
        origin_domain = Project.host_from_url(request.origin)
        return if origin_domain == current_project.domain

        render json: { code: :wrong_domain, message: 'Incorrect domain' }, status: :forbidden
      end
    end
  end
end
