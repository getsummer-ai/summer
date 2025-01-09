# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include EmailablesCollectorConcern

  helper :email
  default from: ENV.fetch('MAILER_DEFAULT_FROM')
end
