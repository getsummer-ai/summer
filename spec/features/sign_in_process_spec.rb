# frozen_string_literal: true
#
describe "the SignIn process" do
  before do
    User.create(
      email: 'admin@test.com',
      password: '12345678',
      password_confirmation: '12345678',
      confirmed_at: Time.zone.now
    )
  end

  it "signs me in" do
    visit "/users/sign_in"
    within("#new_user") do
      fill_in 'Email', with: 'admin@test.com'
      fill_in 'Password', with: '12345678'
    end
    click_button 'Sign in'

    expect(page).to have_content 'Photo Magic'
    expect(page).to have_content 'Upload photos'
  end
end
