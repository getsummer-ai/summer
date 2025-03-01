# frozen_string_literal: true
# Extends +ActionMailer+ with methods for Email management.
module LocaleConcern
  extend ActiveSupport::Concern

  included do
    before_action :use_accept_language,
                  if: -> do
                    request.get? && request.env['HTTP_ACCEPT_LANGUAGE'].present? &&
                      session[:locale].blank? && params[:locale].blank?
                  end
    around_action :switch_locale
  end

  def switch_locale(&)
    locale = params[:locale] || I18n.default_locale
    locale = I18n.default_locale unless I18n.available_locales.include?(locale.to_sym)
    I18n.with_locale(locale, &)
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
