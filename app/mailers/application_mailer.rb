# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  helper :email
  default from: ENV.fetch('MAILER_DEFAULT_FROM')
end
