# frozen_string_literal: true
class ErrorsController < ApplicationController
  skip_before_action :authenticate_user!, :update_user_locale!
  layout :custom_layout

  protect_from_forgery except: :not_found

  # Overloading the default switch_locale
  def switch_locale(&)
    locale = session[:locale] || I18n.default_locale
    locale = I18n.default_locale unless I18n.available_locales.include?(locale.to_sym)
    I18n.with_locale(locale, &)
  end

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: "not_found" }, status: :not_found }
      format.js { head :not_found }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { error: "internal_server_error" }, status: :internal_server_error }
    end
  end


  def custom_layout
    return 'private' if current_user.present?
    'error'
  end
end
