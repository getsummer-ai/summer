# frozen_string_literal: true
class DeviseMailerPreview < ActionMailer::Preview
  # We do not have confirmable enabled, but if we did, this is
  # how we could generate a preview:
  # def confirmation_instructions
  #   Devise::Mailer.confirmation_instructions(User.first, "faketoken")
  # end

  def reset_password_instructions
    DeviseMailer.reset_password_instructions(User.first, "faketoken")
  end

  # def email_changed
  #   Devise::Mailer.email_changed(User.first)
  # end

  def password_changed
    DeviseMailer.password_change(User.first)
  end
end
