# frozen_string_literal: true
module EmailHelper
  def absolute_url(path)
    return path if path.start_with?('http')

    assets_host = ENV.fetch("ASSETS_HOST", nil)

    if assets_host.present?
      return URI.join(assets_host, path).to_s
    end

    host = ActionMailer::Base.default_url_options[:host]
    port = ActionMailer::Base.default_url_options[:port]

    protocol = Rails.env.production? ? 'https' : 'http'
    URI.join("#{protocol}://#{[host, port].compact.join(':')}", path).to_s
  end
end
