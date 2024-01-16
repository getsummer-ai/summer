# frozen_string_literal: true
#
class Users::SessionsController < Devise::SessionsController
  # def after_sign_out_path_for(_resource_or_scope)
  #
  # end
  def after_sign_in_path_for(resource_or_scope)
    return root_path(locale: resource.locale) if resource.is_a?(User)
    stored_location_for(resource_or_scope) || root_path
  end
end
