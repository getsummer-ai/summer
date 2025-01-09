# frozen_string_literal: true
module Emails
  #
  # Provides observer class for emails delivery.
  #
  module ActionMailerObserver
    # @param [Mail::Message] message delivered mail message
    def self.delivered_email(message)
      return unless Emails.store?
      Emails::Updater.new(message).call if message.perform_deliveries
    end
  end
end
