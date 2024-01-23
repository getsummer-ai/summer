# frozen_string_literal: true

require_relative 'boot'
require 'rails'

%w[
  active_record/railtie
  action_controller/railtie
  action_view/railtie
  action_mailer/railtie
  active_job/railtie
  action_cable/engine
  action_mailbox/engine
  action_text/engine
  rails/test_unit/railtie
].each do |railtie|
  begin
    require railtie
  rescue LoadError
  end
end

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Summer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    config.middleware.delete Rack::Runtime

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_job.queue_adapter = :good_job

    config.action_view.preload_links_header = false

    config.exceptions_app = self.routes

    config.to_prepare do
      Rails.application.reload_routes!
      Devise::SessionsController.layout 'login'
      Devise::RegistrationsController.layout proc { |_controller|
                                               user_signed_in? ? 'private' : 'login'
                                             }
      Devise::ConfirmationsController.layout 'login'
      Devise::UnlocksController.layout 'login'
      Devise::PasswordsController.layout 'login'
    end

    # Rails generators configuration
    config.generators { |g| g.test_framework :rspec, fixture: false }
  end
end
