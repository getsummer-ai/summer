# frozen_string_literal: true
# Extends +ActionMailer+ with methods for Email management.
module EmailablesCollectorConcern
  extend ActiveSupport::Concern

  included do
    after_action :set_emails_headers
  end

  # Collect models instantiated in a mail action. +@_message+ is a Mail::Message instance.
  def set_emails_headers
    # Here we collect all models that are instantiated in the mail action
    # and store them in the message headers.
    # This is needed for the Emails::Updater to attach them to the email.
    emailables = Emails::EmailablesCollector.new(self).perform
    emailables_array = emailables.map do |model|
      { model_id: model.id, model_type: model.class.name }
    end
    # Store models in the message headers
    @_message['X-SM-Emailables'] ||= emailables_array
    @_message['X-SM-MailerName'] ||= self.class.name
    @_message['X-SM-ActionName'] ||= action_name
  end
end
