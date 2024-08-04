# frozen_string_literal: true

Rails.configuration.summer = {
  IS_PLAYGROUND: ENV.fetch('PLAYGROUND_MODE', nil) == 'true',
}
