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

      respond_to :json

      private

      # @return [Project]
      def current_project
        @current_project ||= Project.find_by(uuid: request.headers[:HTTP_API_KEY])
      end

      def validate_api_key
        return if request.headers[:HTTP_API_KEY].present? && current_project.present?
        render json: { message: 'Invalid Api-Key' }, status: :forbidden
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
