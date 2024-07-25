# frozen_string_literal: true
module Api
  module V1
    module Pages
      #
      # Controller with basic logic for getting article summary
      #
      class UsersController < DefaultController
        before_action { |_| authorize current_project, :use_subscription_feature? }

        def subscribe
          existed_model = ProjectUserEmail.find_by(encrypted_page_id: params[:page_id])
          return head(:unprocessable_entity) if existed_model.present?

          email = params[:email]
          return head(:no_content) if @current_project.user_emails.exists?(email:)

          @model = @current_project.user_emails.new(email:, encrypted_page_id: params[:page_id], project_page:)
          @model.save
          head(@model.errors.empty? ? :no_content : :unprocessable_entity)
        end
      end
    end
  end
end
