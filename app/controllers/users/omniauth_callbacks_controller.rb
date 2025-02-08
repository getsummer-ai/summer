# frozen_string_literal: true

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    include AuthFlashScriptConcern

    before_action :initiate_user, only: %i[google_oauth2]

    def google_oauth2
      sign_out_all_scopes
      flash[:success] = t 'devise.omniauth_callbacks.success', kind: 'Google'
      if @user.previously_new_record?
        set_flash_js_code_after_registration
      else
        set_flash_js_code_after_authentication
      end

      @user.update_google_oauth2_data(auth)
      Rails.logger.warn "User Google: #{@user.errors.full_messages.join(', ')}" if @user.errors.any?

      sign_in_and_redirect @user, event: :authentication
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

    def initiate_user
      @user = find_or_create_user(auth.info.email, session[:locale])

      return if @user.errors.empty?

      Rails.logger.error "User Google: #{@user.errors.full_messages.join(', ')}"
      flash[:alert] = t 'devise.omniauth_callbacks.failure',
        kind: 'Google',
        reason: "#{auth.info.email} is not authorized."
      redirect_to new_user_session_path
    end

    def find_or_create_user(email, locale)
      User
        .where(email:)
        .first_or_create do |u|
          u.password = Devise.friendly_token
          u.locale = locale if User.locales.value?(locale.to_s)
        end
    end

    def auth
      @auth ||= request.env['omniauth.auth']
    end
  end
end
