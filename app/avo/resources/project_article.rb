# frozen_string_literal: true
module Avo
  module Resources
    class ProjectArticle < Avo::BaseResource
      self.model_class = ::AvoProjectArticle
      self.includes = []
      # self.search = {
      #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
      # }
      self.search = {
        query: -> { query.ransack(article_hash_or_title_i_cont: params[:q]).result(distinct: false) },
        item: -> { { title: "[#{record.id}] #{record.article_hash} :: #{record.title}" } },
      }

      def fields
        field :project, as: :belongs_to, use_resource: Avo::Resources::Project
        field :id, as: :id
        field :preview, as: :preview, hide_on: [:show]
        # field :project_id, as: :number, hide_on: [:index]
        field :article_hash, as: :text, hide_on: [:index]
        field :title, as: :text
        field :article, as: :textarea
        field :status, as: :select, enum: ::ProjectArticle.statuses
        field :tokens_in_count, as: :number
        field :tokens_out_count, as: :number
        field :llm, as: :select, enum: ::ProjectArticle.llms, hide_on: [:index], show_on: :preview
        field :service_info, as: :key_value
        field :image_url, as: :textarea
        field :last_modified_at, as: :date_time, hide_on: [:index], show_on: :preview
        field :last_scraped_at, as: :date_time, hide_on: [:index], show_on: :preview
        field :summarized_at, as: :date_time, hide_on: [:index], show_on: :preview
        field :summary, as: :markdown
        field :project_urls, as: :has_many, resource: Avo::Resources::ProjectUrl

        field :events, as: :has_many, resource: Avo::Resources::Event
        # field :project_article_statistics, as: :has_many
      end
    end
  end
end
