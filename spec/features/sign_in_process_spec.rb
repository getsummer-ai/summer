# frozen_string_literal: true
#
describe "the Sign In process" do

  context 'when user is not logged in' do
    it 'redirects to the sign-in page' do
      visit '/'
      expect(page).to have_current_path new_user_session_path
      expect(page).to have_content 'Create an account'
      expect(page).to have_content 'Restore password'
      expect(page).to have_button("Sign in")
    end

    it 'checks sign-up link' do
      visit new_user_session_path
      click_on 'Create an account'
      expect(page).to have_current_path new_user_registration_path
      expect(page).to have_content 'Sign in'
      expect(page).to have_button("Create Account")
    end
  end

  context 'when user is logged in' do
    include_context 'user login'

    it "signs me in" do
      create_default_user
      login_as_default_user
      expect(page).to have_current_path new_project_path
    end

    it "logs out by pressing a button" do
      create_default_user
      login_as_default_user

      expect(page).to have_current_path new_project_path
      click_on 'Log Out'
      expect(page).to have_current_path new_user_session_path
    end

    it "creates a project after logging" do
      create_default_user
      login_as_default_user
      expect(page).to have_content 'Create new project'
      within("#new_project_form") do
        fill_in 'Project Name', with: ''
        fill_in 'Domain Address', with: 'localhost.com'
      end
      click_on 'Create Project'

      expect(page).to have_content 'Name can\'t be blank'
      expect(page).to have_content 'Urls is not a valid URL'

      within("#new_project_form") do
        fill_in 'Project Name', with: 'My new project'
        fill_in 'Domain Address', with: 'https://localhost.com'
      end

      click_on 'Create Project'
      expect(page).to have_current_path setup_project_path(Project.take)
      expect(page).to have_content 'Code Snippet'
      expect(page).to have_content 'Copy Code'
    end

    it "redirects to the setup page if a project already exists" do
      create_default_user
      project = login_as_default_user(project_exists: true)

      expect(page).to have_current_path setup_project_path(project)
      expect(page).to have_content 'Code Snippet'
      expect(page).to have_content 'Copy Code'
    end
  end
end
