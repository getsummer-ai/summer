# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with common logic for user API
    #
    class ButtonController < Api::V1::ApplicationController
      before_action :validate_origin
      before_action :validate_init_request, only: :init
      wrap_parameters false

      def init
        @article = ProjectArticleForm.new(current_project, article_url).find_or_create
        return head :bad_request if @article.blank?
        render 'init', status: :ok
      end

      def summary
        @article =
          current_project.project_articles.summary_columns.find_by!(article_hash: permitted_params[:id])
        @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(filter_html: true))
        @html_summary = Base64.encode64(@markdown.render(@article&.summary || ''))
      end

      private

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
        params.permit(:s, :id)
      end
    end
  end
end
