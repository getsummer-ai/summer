# frozen_string_literal: true

require_relative 'boot'
require 'rails'
# require 'rails/all'

require 'active_record/railtie'

# Enabled only because of the avo 3.12.0 version
# https://github.com/avo-hq/avo/pull/3215
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
require 'action_cable/engine'
# require 'action_mailbox/engine'
# require 'action_text/engine'
require 'rails/test_unit/railtie'

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
    # config.autoload_paths += %W(#{config.root}/app/view_models/**/*)
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
      Devise::ConfirmationsController.layout 'login'
      Devise::UnlocksController.layout 'login'
      Devise::PasswordsController.layout 'login'
    end

    # Rails generators configuration
    config.generators { |g| g.test_framework :rspec, fixture: false }
  end
end
