# frozen_string_literal: true
#
describe 'the Navigation process' do
  include_context 'user login'

  before do
    WebMock.disable_net_connect!(allow: '127.0.0.1')
    create_default_user
    login_as_default_user(project_exists: true)
  end

  let(:project) { Project.take }

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
