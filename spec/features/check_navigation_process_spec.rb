# frozen_string_literal: true
#
describe 'the Navigation process' do
  context 'when user is not logged in' do
    it 'sign-in redirect' do
      visit '/'
      click_link id: 'try-button'

      expect(page).to have_current_path new_user_session_path

      expect(page).to have_content 'Log in'
      expect(page).to have_content 'Sign up'
      expect(page).to have_content 'Forgot your password?'
    end

    it 'checks sign-up link' do
      visit new_user_session_path
      click_link 'Sign up'
      expect(page).to have_current_path new_user_registration_path
      expect(page).to have_content 'Log in'
      expect(page).to have_content 'Sign up'

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
      User.create(
        email: 'admin@test.com',
        password: '12345678',
        password_confirmation: '12345678',
        confirmed_at: Time.zone.now,
      )

      visit "/users/sign_in"
      within("#new_user") do
        fill_in 'Email', with: 'admin@test.com'
        fill_in 'Password', with: '12345678'
      end
      click_button 'Sign in'
    end

    it 'redirects user from main page to app' do
      visit '/'
      expect(find_by_id('try-button')[:href]).to include '#/app'
      expect(page).to have_content 'Logout'
      click_link id: 'try-button'
      expect(page).to have_current_path root_path
    end
  end
end
