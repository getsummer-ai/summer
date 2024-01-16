# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :use_accept_language,
                if: -> {
                  request.get? && request.env['HTTP_ACCEPT_LANGUAGE'].present? &&
                    session[:locale].blank? && params[:locale].blank?
                }
  around_action :switch_locale
  before_action :authenticate_user!
  before_action :set_locale

  def switch_locale(&)
    locale = params[:locale] || I18n.default_locale
    locale = I18n.default_locale unless I18n.available_locales.include?(locale.to_sym)
    I18n.with_locale(locale, &)
  end

  def set_locale
    locale = I18n.locale
    u = current_user
    u.update_attribute(:locale, locale) if u.present? && u.locale != locale
    session[:locale] = locale if session[:locale] != locale
  end

  def default_url_options(options = {})
    locale = I18n.locale == I18n.default_locale ? nil : I18n.locale
    options.merge({ locale: })
  end

  def use_accept_language
    browser_language = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    return if browser_language.nil?
    return unless I18n.available_locales.include?(browser_language.to_sym)
    return if browser_language.to_sym == I18n.default_locale
    redirect_to url_for(request.params.merge(locale: browser_language))
  end
end
