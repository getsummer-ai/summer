# frozen_string_literal: true
#
# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/api/v1/*',
             headers: 'Api-Key',
             methods: %i[get post options head]
    resource '/libs/*',
             headers: :any,
             methods: %i[get post put patch delete options head]
  end

  # allow do
  #   origins '*'
  #   resource '/public/*', headers: :any, methods: :get
  #     # origins 'vite*/assets/pixels' do |source, env|
  #     #   Project.exists?(['domain  ~* ?', "^#{source}"])
  #     # end
  #
  #   # Only allow a request for a specific host
  #   resource '/api/v1/*',
  #            headers: :any,
  #            methods: :get,
  #            if: proc { |env| env['HTTP_HOST'] == 'api.example.com' }
  # end
end
