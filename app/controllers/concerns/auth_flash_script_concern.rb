# frozen_string_literal: true
module AuthFlashScriptConcern
  def set_flash_js_code_after_registration
    flash[:script] = <<~JS
      window.dataLayer = window.dataLayer || [];
      window.dataLayer.push({ 'event': 'SignUp' });
    JS
  end

  def set_flash_js_code_after_authentication
    flash[:script] = <<~JS
      window.dataLayer = window.dataLayer || [];
      window.dataLayer.push({ 'event': 'SignIn' });
    JS
  end
end
