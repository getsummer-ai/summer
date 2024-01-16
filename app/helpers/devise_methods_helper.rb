# frozen_string_literal: true
module DeviseMethodsHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= request.env["devise.mapping"].presence || Devise.mappings[:user]
  end
end
