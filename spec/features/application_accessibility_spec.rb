# frozen_string_literal: true
#
describe 'main application accessibility' do
  before(:all) do
    user = User.create(
      email: 'admin@test.com',
      password: '12345678',
      password_confirmation: '12345678',
      confirmed_at: Time.zone.now,
    )
    user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
  end

  context 'when user is not logged in', :js do
    it 'opens a login modal when click on try button' do
      visit '/'

      expect(find_by_id('try-button')[:href]).to include login_modals_path
      click_link id: 'try-button'
      expect(page).to have_current_path root_path

      section = find_by_id('modal')

      within(section) do
        expect(find_by_id('modal-title')).to have_content 'Sign In'

        within("#new_user") do
          fill_in 'Email', with: 'admin@test.com'
          fill_in 'Password', with: '12345678'
        end
        click_button 'Sign in'
      end

      expect(page).to have_link 'Upload photos', href: '#/app'
    end
  end


  context 'when user is logged in' do
    before do
      visit "/users/sign_in"
      within("#new_user") do
        fill_in 'Email', with: 'admin@test.com'
        fill_in 'Password', with: '12345678'
      end
      click_button 'Sign in'
    end

    it 'redirects user from main page to app', :js do
      expect(page).to have_content(/upload photos/i)
      visit '/'
      click_link id: 'try-button'
      expect(page).to have_current_path root_path
      expect(page).to have_content 'Click to upload or drag and drop'
    end
  end
end
