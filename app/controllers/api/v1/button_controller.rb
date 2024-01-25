# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with common logic for user API
    #
    class ButtonController < Api::V1::ApplicationController
      before_action :validate_origin
      before_action :validate_init_request, only: :init

      def init
        @article = ProjectArticleForm.new(current_project, article_url).find_or_create
        return head :bad_request if @article.blank?
        render 'init', status: :ok
      end

      def summary
        @article =
          current_project.project_articles.summary_columns.find_by!(article_hash: params[:id])
      end

      private

      def validate_init_request
        return head(:bad_request) if article_url.blank?

        article_url_domain = Project.host_from_url(article_url)
        return if article_url_domain == current_project.domain

        render json: { code: :wrong_domain, message: 'Incorrect domain' }, status: :forbidden
      end

      # @return [String]
      def article_url
        @article_url ||= params.permit(:s)['s'].to_s
      end
    end
  end
end
