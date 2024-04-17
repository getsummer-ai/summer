# frozen_string_literal: true
RSpec.shared_context 'user login' do
  include SpecTestHelper

  def login_as_default_user(project_exists: false)
    project = nil
    if project_exists
      project = User.take.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
    end
    visit "/users/sign_in"
    within("#new_user") do
      fill_in 'Email', with: 'admin@test.com'
      fill_in 'Password', with: '12345678'
    end
    click_on 'Sign in'
    project
  end
end
