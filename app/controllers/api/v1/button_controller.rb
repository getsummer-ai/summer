# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with common logic for user API
    #
    class ButtonController < Api::V1::ApplicationController
      before_action :validate_init_request, only: :init

      def settings
        @app_path =
          Rails.env.production? ? '/libs/app.umd.js' : helpers.vite_asset_path('libs/summer.ts')
      end

      def init
        form = ProjectArticleForm.new(current_project, article_url)
        return head :bad_request unless form.valid?

        @article = form.find_or_create
        return head :bad_request if @article.nil?
        return head :not_found if @article.status_summary_skipped? || @article.status_summary_error?

        @combined_id =
          BasicEncrypting.encode_array([form.project_page.id, 4.hours.from_now.utc.to_i])
        update_statistics form.project_page
      end

      private

      # @param [ProjectPage] project_page
      def update_statistics(project_page)
        ArticleStatisticService.new(project: @current_project, trackable: project_page).view!
      end

      def validate_init_request
        return head(:bad_request) if article_url.blank?
        parsed_url = Project.parse_url(article_url)

        if parsed_url.nil? || parsed_url.host != current_project.domain
          return send_incorrect_domain_response!
        end

        return unless @current_project.paths.find { |path| parsed_url.path.start_with?(path) }.nil?

        send_incorrect_path_response!
      end

      # @return [String]
      def article_url
        @article_url ||= permitted_params['s'].to_s
      end

      def permitted_params
        params.permit(:s)
      end

      def send_incorrect_path_response!
        render json: { code: :forbidden_path, message: 'Forbidden path' }, status: :forbidden
      end
    end
  end
end
