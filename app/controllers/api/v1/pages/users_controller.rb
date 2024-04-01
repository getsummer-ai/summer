# frozen_string_literal: true
module Api
  module V1
    module Pages
      #
      # Controller with basic logic for getting article summary
      #
      class UsersController < DefaultController
        def subscribe
          existed_model = ProjectUserEmail.find_by(encrypted_page_id: params[:page_id])
          return head(:unprocessable_entity) if existed_model.present?

          email = params[:email]
          return head(:ok) if @current_project.user_emails.exists?(email:)

          @model = @current_project.user_emails.new(email:, encrypted_page_id: params[:page_id], project_page:)
          @model.save
          head(@model.errors.empty? ? :ok : :unprocessable_entity)
        end
      end
    end
  end
end
