# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with common logic for user API
    #
    class ButtonController < Api::V1::ApplicationController
      before_action :validate_init_request, only: :init

      wrap_parameters false

      def version
        app_path = Rails.env.production? ? "/libs/app.umd.js" : helpers.vite_asset_path('libs/summer.ts')
        render json: { path: app_path }
      end

      def init
        form = ProjectArticleForm.new(current_project, article_url)
        return head :bad_request unless form.valid?

        @article = form.find_or_create
        return head :bad_request if @article.nil?
        return head :not_found if @article.status_summary_skipped? || @article.status_summary_error?

        @url_id = form.project_url.id
        @combined_id = BasicEncrypting.encode_array([@article.id, @url_id, 4.hours.from_now.utc.to_i])
        update_statistics @url_id, @article.id
      end

      private

      def update_statistics(url_id, article_id)
        ArticleStatisticService.new(url_id:, article_id:).view!
      end

      def validate_init_request
        return head(:bad_request) if article_url.blank?

        article_url_domain = Project.host_from_url(article_url)
        return if article_url_domain == current_project.domain

        send_incorrect_domain_response!
      end

      # @return [String]
      def article_url
        @article_url ||= permitted_params['s'].to_s
      end

      def permitted_params
        params.permit(:s)
      end
    end
  end
end
