# frozen_string_literal: true
module Users
  class RegistrationsController < Devise::RegistrationsController
    include AuthFlashScriptConcern
    include FramerAuthSessionConcern
    before_action :sanitize_framer_session_id_param, only: %i[create]
    before_action :sanitize_sign_up_params, only: %i[create]
    before_action :clear_framer_auth_session_if_no_param, only: %i[new create]

    layout proc { |_|
      next 'private' if user_signed_in?

      if params[:framer_session_id].present? && framer_auth_session_id.present?
        next 'framer_login'
      end

      'login'
    }

    def create
      build_resource(sign_up_params)

      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          # set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          set_flash_js_code_after_registration
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end

    # DELETE /resource
    def destroy
      resource.soft_delete
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      set_flash_message :notice, :destroyed
      yield resource if block_given?
      respond_with_navigational(resource) { redirect_to after_sign_out_path_for(resource_name) }
    end

    def update_resource(resource, params)
      if resource.provider == 'google_oauth2'
        params.delete('current_password')
        resource.password = params['password']
        resource.update_without_password(params)
        return
      end
      resource.update_with_password(params)
    end

    def after_sign_up_path_for(resource)
      user_app_path(locale: resource.locale)
    end

    def sanitize_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:locale])
    end

    def account_update_params
      devise_parameter_sanitizer.sanitize(:account_update).slice(:password, :password_confirmation, :current_password)
    end

    def sanitize_framer_session_id_param
      devise_parameter_sanitizer.permit(:sign_up, keys: [:framer_session_id])
    end
  end
end
