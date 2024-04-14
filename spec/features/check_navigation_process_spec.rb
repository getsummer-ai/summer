# frozen_string_literal: true
#
describe 'the Navigation process' do
  context 'when user is not logged in' do
    it 'sign-in redirect' do
      visit '/'
      expect(page).to have_current_path new_user_session_path
      expect(page).to have_content 'Sign in'
      expect(page).to have_content 'Sign up'
      expect(page).to have_content 'Forgot your password?'
    end

    it 'checks sign-up link' do
      visit new_user_session_path
      click_on 'Sign up'
      expect(page).to have_current_path new_user_registration_path
      expect(page).to have_content 'Log in'
      expect(page).to have_button("Create Account")

      # click_link "Didn't receive confirmation instructions?"
      # expect(page).to have_current_path new_user_confirmation_path
    end

    # it 'checks confirmation link availability' do
    #   visit new_user_session_path
    #   click_link "Didn't receive confirmation instructions?"
    #   expect(page).to have_current_path new_user_confirmation_path
    #   expect(page).to have_content 'Resend confirmation instructions'
    # end
  end

  context 'when user is logged in' do
    before do
      # WebMock.allow_net_connect!
      WebMock.disable_net_connect!(allow: '127.0.0.1')

      user = User.create(
        email: 'admin@test.com',
        password: '12345678',
        password_confirmation: '12345678',
        confirmed_at: Time.zone.now,
      )
      user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')

      visit "/users/sign_in"
      within("#new_user") do
        fill_in 'Email', with: 'admin@test.com'
        fill_in 'Password', with: '12345678'
      end
      click_on 'Sign in'
    end

    let(:project) { Project.take }

    it 'redirects after login to the default setup page' do
      expect(page).to have_current_path setup_project_path(project)
      expect(page).to have_content 'Code Snippet'
      expect(page).to have_content 'Copy Code'
    end

    it 'checks menu links' do
      # expect(find_by_id('try-button')[:href]).to include '#/app'
      click_on 'Setup'
      expect(page).to have_current_path setup_project_path(project)

      expect(page).to have_link('Setup', href: setup_project_path(project))
      expect(page).to have_link('Knowledge', href: knowledge_project_path(project))
      expect(page).to have_link('Pages', href: project_pages_path(project))
      expect(page).to have_link('Actions', href: project_actions_path(project))
      expect(page).to have_link('Settings', href: project_settings_path(project))
      expect(page).to have_button('Logout')
    end

    describe "checking every section", :js do
      it 'check the guidelines on the knowledge page' do
        click_on 'Knowledge'
        expect(page).to have_content 'Knowledge'
        expect(page).to have_content 'Guidelines'

        text = 'Use the company name in the CamelCase form'
        find_by_id('project_guidelines').fill_in with: text
        using_wait_time 3 do
          expect(page).to have_content 'Guidelines were successfully updated'
        end
        visit current_path
        expect(page).to have_field("project_guidelines", with: text)
      end

      it 'check the products section on the knowledge page' do
        click_on 'Knowledge'
        expect(page).to have_content 'Products'
        click_on '+ Add new product'

        using_wait_time 3 do
          expect(page).to have_content 'Product or Service'
        end

        within("#new_project_product") do
          fill_in 'Name', with: 'admin@test.com'
          fill_in 'Link', with: '12345678'
          fill_in 'Description', with: '12345678'
        end

        click_on 'Add product'

        expect(page).to have_content 'Link must be a valid url'

        within("#new_project_product") do
          fill_in 'Name', with: 'Test product name'
          fill_in 'Link', with: 'https://enty.io/blog/accounting-automation-with-enty'
          fill_in 'Description', with: '12345678'
        end

        allow(ProjectProductLinkScrapeJob).to receive(:perform_later).and_return(true)

        click_on 'Add product'

        using_wait_time 2 do
          expect(page).to have_content 'Test product name'
        end
      end
    end
  end
end
