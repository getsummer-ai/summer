# frozen_string_literal: true
#
module Users
  class SessionsController < Devise::SessionsController
    before_action :remove_authentication_flash_message_if_root_url_requested
    # def after_sign_out_path_for(_resource_or_scope)
    #
    # end
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
