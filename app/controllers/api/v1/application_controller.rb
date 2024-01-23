# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with common logic for user API
    #
    class ApplicationController < ActionController::API
      before_action :request_validation
      helper_method :current_project

      respond_to :json

      private

      # @return [Project, nil]
      def current_project
        @current_project ||= Project.find_by(id: request.headers[:HTTP_API_TOKEN])
      end

      def request_validation
        return if request.headers[:HTTP_API_TOKEN].present? && current_project.present?
        render json: { message: 'Invalid API token' }, status: :forbidden
      end
    end
  end
end
