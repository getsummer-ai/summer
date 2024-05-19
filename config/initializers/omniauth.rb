# frozen_string_literal: true
#
# Errors from authentication may crash because no Devise mapping is defined
# for the callback path. To work around this we manually set the failure
# callback to Users::OmniauthCallbacksController.failure().
#
# See https://github.com/plataformatec/devise/issues/2004#issuecomment-7466322
# for more information.
OmniAuth.config.on_failure = proc do |env|
  env["devise.mapping"] = Devise.mappings[:user]
  controller_name = ActiveSupport::Inflector.camelize(env["devise.mapping"].controllers[:omniauth_callbacks])
  controller_klass = ActiveSupport::Inflector.constantize("#{controller_name}Controller")
  controller_klass.action(:failure).call(env)
end
