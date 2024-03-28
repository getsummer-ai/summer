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

        @services = @current_project.services
                    .select('id', 'title', 'description', "encode(icon, 'base64') as icon", 'uuid', 'link')
                    .where(id: project_article_query)
      end
    end
  end
end
