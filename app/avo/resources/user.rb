module Avo
  module Resources
    class User < Avo::BaseResource
      self.model_class = AvoUser
      self.includes = []
      self.search = {
        query: -> { query.ransack(email_or_name_i_cont: params[:q]).result(distinct: false) },
        item: -> do
          {
            title: "[#{record.id}] #{record.email} :: #{record.name}",
          }
        end
      }

      def fields
        # field :preview, as: :preview, hide_on: [:show]
        field :id, as: :id
        field :email, as: :text
        field :sign_in_count, as: :number, show_on: :preview, hide_on: [:index]
        field :current_sign_in_at, as: :date_time, show_on: :preview, hide_on: [:index]
        field :last_sign_in_at, as: :date_time
        field :current_sign_in_ip, as: :text, show_on: :preview, hide_on: [:index]
        field :last_sign_in_ip, as: :text, show_on: :preview, hide_on: [:index]
        field :confirmation_token, as: :text, show_on: :preview, hide_on: [:index]
        field :confirmed_at, as: :date_time, show_on: :preview, hide_on: [:index]
        field :confirmation_sent_at, as: :date_time, show_on: :preview, hide_on: [:index]
        field :unconfirmed_email, as: :text, show_on: :preview, hide_on: [:index]
        field :failed_attempts, as: :number, show_on: :preview, hide_on: [:index]
        field :unlock_token, as: :text, show_on: :preview, hide_on: [:index]
        field :locked_at, as: :date_time, show_on: :preview, hide_on: [:index]
        field :provider, as: :text
        field :uid, as: :text, show_on: :preview, hide_on: [:index]
        field :name, as: :text, show_on: :preview, hide_on: [:index]
        field :avatar_url, as: :textarea, show_on: :preview, hide_on: [:index]
        field :locale, as: :select, enum: ::User.locales, show_on: :preview, hide_on: [:index]
        field :is_admin, as: :boolean
        field :deleted_at, as: :date_time, show_on: :preview, hide_on: [:index]
        field :default_project_id, as: :number, show_on: :preview, hide_on: [:index]
        # field :events, as: :has_many
        field :default_project, as: :belongs_to, use_resource: Avo::Resources::Project
        field :projects, as: :has_many, use_resource: Avo::Resources::Project
        field :all_events, as: :has_many, resource: Avo::Resources::Event
      end
    end
  end
end
