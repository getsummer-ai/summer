# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with basic logic for getting article summary
    #
    class ProductsController < Api::V1::ApplicationController
      include ProjectPageConcern

      def show
        project_article_query = ProjectArticleService
                                .select('project_service_id')
                                .where(project_article_id: project_page.project_article_id)

        @services = @current_project.services.where(id: project_article_query).only_main_columns.icon_as_base64

        @services.each do |service|
          StatisticService.new(project: @current_project, trackable: service).view!
        end
      end

      def click
        service = @current_project.services.select('id').find_by!(uuid: params[:uuid])
        StatisticService.new(project: @current_project, trackable: service).click!
        head :ok
      end
    end
  end
end
