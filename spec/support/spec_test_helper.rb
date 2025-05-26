# frozen_string_literal: true

module SpecTestHelper
  def create_default_user(attributes = {})
    User.create({
      email: 'admin@test.com',
      password: '12345678',
      password_confirmation: '12345678',
      confirmed_at: Time.zone.now
    }.merge!(attributes))
  end

  def login_user(user = nil)
    user ||= create_default_user
    user.confirm unless user.confirmed_at?
    request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
    user
  end

  def create_default_project_for(user)
    user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
  end

  # @project [Project]
  def create_default_subscription_for(project, **options)
    sub = {
        plan: 'free',
        start_at: Time.zone.now,
        end_at: 10.years.from_now,
        summarize_usage: 0,
        summarize_limit: 500
    }.merge(options)
    project.subscriptions.create!(sub).tap { |s| project.update!(subscription: s) }
  end
end
