# frozen_string_literal: true

module Avo
  module Resources
    class Project < Avo::BaseResource
      self.model_class = ::AvoProject
      self.includes = []
      # self.search = {
      #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
      # }
      self.search = {
        query: -> { query.ransack(name_or_domain_i_cont: params[:q]).result(distinct: false) },
        item: -> do
          {
            title: "[#{record.id}] #{record.name} :: #{record.domain}",
          }
        end
      }

      def fields
        field :user, as: :belongs_to, resource: Avo::Resources::User
        field :id, as: :id, link_to_record: true
        field :preview, as: :preview, hide_on: [:show]
        # field :uuid, as: :text
        field :user_id, as: :number, show_on: :preview, hide_on: [:index]
        field :name, as: :text
        field :domain, as: :text
        field :plan, as: :select, enum: ::Project.plans
        field :status, as: :select, enum: ::Project.statuses
        field :settings, as: :key_value, hide_on: [:index], show_on: :preview
        # field :settings, as: :code, language: 'javascript', hide_on: [:index], show_on: :preview
        field :default_llm, as: :select, enum: ::Project.default_llms, hide_on: [:index], show_on: :preview
        field :created_at, as: :date_time
        field :deleted_at, as: :date_time, hide_on: [:index]
        # field :events, as: :has_many, polymorphic_as: 'Avo::Project'
        field :project_urls, as: :has_many, resource: Avo::Resources::ProjectUrl
        field :all_events, as: :has_many, resource: Avo::Resources::Event
        # field :project_urls, as: :has_many
        # field :project_articles, as: :has_many
        # field :project_article_statistics, as: :has_many, through: :project_articles
      end
    end
  end
end
