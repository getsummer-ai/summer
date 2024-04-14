# frozen_string_literal: true

module SpecTestHelper
  def create_default_user
    User.create(
      email: 'admin@test.com',
      password: '12345678',
      password_confirmation: '12345678',
      confirmed_at: Time.zone.now
    )
  end

  def login_user(user = nil)
    user ||= create_default_user
    user.confirm unless user.confirmed_at?
    request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
    user
  end
end
