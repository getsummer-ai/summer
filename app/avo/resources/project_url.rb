# frozen_string_literal: true
module Avo
  module Resources
    class ProjectUrl < Avo::BaseResource
      self.model_class = ::AvoProjectUrl

      self.includes = []
      self.search = {
        query: -> { query.ransack(url_or_url_hash_i_cont: params[:q]).result(distinct: false) },
        item: -> { { title: "[#{record.id}] [project_id: #{record.id}] #{record.url}" } },
      }

      def fields
        field :id, as: :id
        field :project, as: :belongs_to, use_resource: Avo::Resources::Project
        field :url_hash, as: :text, hide_on: [:index]
        field :url, as: :text
        field :is_accessible, as: :boolean
        # field :project_article_id, as: :number

        field :project_article, as: :belongs_to, use_resource: Avo::Resources::ProjectArticle
        field :events, as: :has_many, resource: Avo::Resources::Event

      end
    end
  end
end
