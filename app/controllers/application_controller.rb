# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include LocaleConcern

  before_action :authenticate_user!
  before_action :update_user_locale!

  def update_user_locale!
    u = current_user
    u.update_attribute(:locale, I18n.locale) if u.present? && u.locale != I18n.locale
    session[:locale] = I18n.locale if session[:locale] != I18n.locale
  end
end
