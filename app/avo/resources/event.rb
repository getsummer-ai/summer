# frozen_string_literal: true

module Avo
  module Resources
    class Event < Avo::BaseResource
      self.includes = []
      # self.search = {
      #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
      # }

      def fields
        field :preview, as: :preview, hide_on: [:show]
        field :id, as: :id
        field :category, as: :text
        field :subcategory, as: :text
        field :trackable_type, as: :text
        field :trackable_id, as: :number
        field :source, as: :text
        field :details, as: :text, show_on: :preview, hide_on: [:index]
        # field :author_type, as: :text, hide_on: [:index]
        # field :author_id, as: :number, hide_on: [:index]
        field :project, as: :belongs_to, use_resource: Avo::Resources::Project
        field :created_at, as: :date_time
        # field :trackable, as: :belongs_to
        field :author, as: :belongs_to, use_resource: Avo::Resources::User
      end
    end
  end
end
