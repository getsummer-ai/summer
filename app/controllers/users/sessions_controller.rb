# frozen_string_literal: true
#
module Users
  class SessionsController < Devise::SessionsController
    include AuthFlashScriptConcern
    before_action :remove_authentication_flash_message_if_root_url_requested

    def create
      self.resource = warden.authenticate!(auth_options)
      # set_flash_message!(:notice, :signed_in)
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
      return unless session[:user_return_to] && flash[:alert] == I18n.t('devise.failure.unauthenticated')
      flash[:alert] = nil
    end
  end
end
