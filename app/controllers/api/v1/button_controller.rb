# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with common logic for user API
    #
    class ButtonController < Api::V1::ApplicationController
      before_action :validate_init_request, only: :init

      FULL_PATH_TO_BUTTON_APP =
        if Rails.env.development?
          helpers.vite_asset_path('libs/summer.ts')
        else
          manifest = JSON.parse(Rails.public_path.join('libs/.vite/manifest.json').read)
          manifest['app/frontend/libs/summer.ts']['file']
          "/libs/#{manifest['app/frontend/libs/summer.ts']['file']}"
        end

      def settings
        @app_path = FULL_PATH_TO_BUTTON_APP
        @settings = current_project.decorate.summary_settings
      end

      def init
        form = ProjectArticleForm.new(current_project, article_url)
        return head :bad_request unless form.valid?

        @article = form.find_or_create
        return head :bad_request if @article.nil?
        if @article.summary_status_skipped? || @article.summary_status_error?
          return head :no_content
        end
        return head :no_content unless form.project_page.is_accessible?

        @combined_id =
          BasicEncrypting.encode_array([form.project_page.id, 4.hours.from_now.utc.to_i])
        update_statistics form.project_page
      end

      private

      # @param [ProjectPage] project_page
      def update_statistics(project_page)
        StatisticService.new(project: @current_project, trackable: project_page).view!
      end

      def validate_init_request
        return head(:bad_request) if article_url.blank?
        parsed_url = Project.parse_url(article_url)

        return send_incorrect_domain_response! if parsed_url.nil?
        return send_incorrect_domain_response! unless current_project.valid_host?(parsed_url.host)

        paths = @current_project.paths
        return if paths.empty? || !paths.find { |path| parsed_url.path.start_with?(path) }.nil?

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
