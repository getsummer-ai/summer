# frozen_string_literal: true
class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  # DELETE /resource
  def destroy
    resource.soft_delete
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed
    yield resource if block_given?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
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

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:locale])
  end
end
