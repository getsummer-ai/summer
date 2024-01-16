# frozen_string_literal: true
class Users::PasswordsController < Devise::PasswordsController

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      respond_with({}, location: new_password_path(:user))
    else
      respond_with(resource)
    end
  end

  # protected
  #
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   root_path if is_navigational_format?
  # end
end
