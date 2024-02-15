# frozen_string_literal: true

module Avo
  module Resources
    class Event < Avo::BaseResource
      self.model_class = ::AvoEvent
      self.includes = []
      # self.search = {
      #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
      # }

      def fields
        visible = -> do
          @params[:resource_name]&.classify == 'Project' ||
            @params[:resource_name]&.classify != @resource&.record&.trackable_type
        end
        field :id, as: :id
        field :project,
              as: :belongs_to,
              use_resource: Avo::Resources::Project,
              visible: -> { @params[:resource_name]&.classify != 'Project' }
        field :category, as: :text, hide_on: [:index]
        field :subcategory, as: :text, hide_on: [:index]
        field(:trackable_type, as: :text, visible:)
        field(:trackable_id, as: :number, visible:)
        field :preview, as: :preview, hide_on: [:show]
        field :source, as: :text
        field :details, as: :text, show_on: :preview, hide_on: [:index]
        # field :author_type, as: :text, hide_on: [:index]
        # field :author_id, as: :number, hide_on: [:index]
        field :created_at, as: :date_time
        # field :trackable, as: :belongs_to
        field :author, as: :belongs_to, use_resource: Avo::Resources::User
      end
    end
  end
end
