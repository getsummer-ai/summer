# frozen_string_literal: true
module RedisFactory
  DEFAULT_CONFIG = Rails.application.config_for(:redis)

  # @return [Redis]
  def self.new
    Redis.new(DEFAULT_CONFIG)
  end
end
