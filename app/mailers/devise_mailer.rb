# frozen_string_literal: true
class DeviseMailer < Devise::Mailer
  helper :email
  layout 'email/mailer'
end
