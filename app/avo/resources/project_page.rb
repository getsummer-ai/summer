# frozen_string_literal: true
module Avo
  module Resources
    class ProjectPage < Avo::BaseResource
      self.model_class = ::AvoProjectPage

      self.includes = []
      self.search = {
        query: -> { query.ransack(url_or_url_hash_i_cont: params[:q]).result(distinct: false) },
        item: -> { { title: "[#{record.id}] [project_id: #{record.id}] #{record.url}" } },
      }

      def fields
        visible = -> {
          @params[:resource_name]&.classify != 'ProjectArticle'
        }
        field :project, as: :belongs_to, use_resource: Avo::Resources::Project,
              visible: -> { @params[:resource_name]&.classify != 'Project' }
        field :id, as: :id
        field :url_hash, as: :text, hide_on: [:index]
        field :url, as: :text
        field :is_accessible, as: :boolean
        # field :project_article_id, as: :number

        field :project_article, as: :belongs_to, use_resource: Avo::Resources::ProjectArticle, visible: visible
        field :events, as: :has_many, resource: Avo::Resources::Event

      end
    end
  end
end
