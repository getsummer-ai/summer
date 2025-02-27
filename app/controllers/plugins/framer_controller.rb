# frozen_string_literal: true
module Plugins
  class FramerController < PluginController

    before_action :clear_devise_session

    def login
      existing_key = ProjectApiKey.find_or_create_by(id: params[:session_id], key_type: 'framer') do |key|
        key.details = { email: params[:email], password: params[:password] }
      end

      # if user&.valid_password?(params[:password])
      #   render json: { token: user.authentication_token }
      # else
      #   render json: { error: 'Invalid email or password' }, status: :unauthorized
      # end
    end

    private

    def clear_devise_session
      sign_out(current_user)
    end
  end
end
