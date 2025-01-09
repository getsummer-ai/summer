# frozen_string_literal: true
class DeviseMailer < Devise::Mailer
  include EmailablesCollectorConcern

  helper :email
  layout 'email/mailer'
end
