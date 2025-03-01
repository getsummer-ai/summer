# frozen_string_literal: true
#
module Users
  class SessionsController < Devise::SessionsController
    include AuthFlashScriptConcern
    include FramerAuthSessionConcern

    protect_from_forgery  with: :exception, prepend: true

    # before_action :sanitize_framer_session_id_param, only: %i[create]
    before_action :clear_framer_auth_session_if_no_param, only: %i[new]
    before_action :remove_authentication_flash_message_if_root_url_requested

    layout proc { |_|
      if params[:framer_session_id].present? && framer_auth_session_id.present?
        next 'framer_login'
      end

      'login'
    }

    def create
      self.resource = warden.authenticate!(auth_options)
      set_flash_js_code_after_authentication
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end

    def after_sign_in_path_for(resource_or_scope)
      # return user_app_path(locale: resource.locale) if resource.is_a?(User)
      stored_location_for(resource_or_scope) || user_app_path(locale: resource_or_scope.locale)
    end

    private

    def remove_authentication_flash_message_if_root_url_requested
      # if (session[:user_return_to] == root_path) && (flash[:alert] == I18n.t('devise.failure.unauthenticated'))
      unless session[:user_return_to] && flash[:alert] == I18n.t('devise.failure.unauthenticated')
        return
      end
      flash[:alert] = nil
    end

    def default_url_options
      { framer_session_id: params[:framer_session_id] }
    end

    # def sanitize_framer_session_id_param
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:framer_session_id, :password, :remember_me])
    # end
  end
end
