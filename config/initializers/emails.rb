# frozen_string_literal: true

# require Rails.root.join("app/lib/emails/action_mailer_observer")

Rails.configuration.after_initialize do
  ActionMailer::Base.register_observer Emails::ActionMailerObserver
end
