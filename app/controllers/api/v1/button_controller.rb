# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with common logic for user API
    #
    class ButtonController < Api::V1::ApplicationController
      before_action :validate_request

      def init
        @article = ProjectArticleForm.new(current_project, project_url).find_or_create
        return head :bad_request if @article.blank?
        render 'init', status: :ok
      end

      private

      def validate_request
        head :bad_request if project_url.blank?
      end

      # @return [String]
      def project_url
        @project_url ||= params.permit(:s)['s'].to_s
      end
    end
  end
end
