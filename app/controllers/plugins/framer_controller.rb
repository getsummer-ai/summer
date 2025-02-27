# frozen_string_literal: true
module Plugins
  class FramerController < PluginController

    def login
      id = params[:id]
      project_id = params[:framer_project_id]

      user = User.find_by(email: params[:email])
      if user&.valid_password?(params[:password])
        render json: { token: user.authentication_token }
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
    
  end
end
