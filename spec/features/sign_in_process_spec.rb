# frozen_string_literal: true
#
describe "the SignIn process" do
  before do
    create_default_user
  end

  it "signs me in" do
    visit "/users/sign_in"
    within("#new_user") do
      fill_in 'Email', with: 'admin@test.com'
      fill_in 'Password', with: '12345678'
    end
    click_on 'Sign in'

    expect(page).to have_content 'Create new project'
    # expect(page).to have_content 'Upload photos'
  end
end
