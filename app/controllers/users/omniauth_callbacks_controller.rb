# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      user = User.from_omniauth(auth, session[:locale])

      if user.present?
        sign_out_all_scopes
        flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect user, event: :authentication
      else
        flash[:alert] = t 'devise.omniauth_callbacks.failure',
          kind: 'Google',
          reason: "#{auth.info.email} is not authorized."
        redirect_to new_user_session_path
      end
    end

    def failure
      flash[:error] = 'There was an error while trying to authenticate you...'
      redirect_to new_user_session_path
    end

    protected

    def after_omniauth_failure_path_for(_scope)
      new_user_session_path
    end

    def after_sign_in_path_for(resource_or_scope)
      stored_location_for(resource_or_scope) || user_app_path
    end

    private

    def auth
      @auth ||= request.env['omniauth.auth']
    end
  end
end
