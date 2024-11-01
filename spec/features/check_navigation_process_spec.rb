# frozen_string_literal: true
#
describe 'the Navigation process' do
  include_context 'user login'
  
  let!(:user) { create_default_user }
  let!(:project) do
    project = user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
    create_default_subscription_for(project)
    project
  end

  before do
    WebMock.disable_net_connect!(allow: '127.0.0.1')
    login_as_default_user
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

      within("#sidebar-menu") do
        click_on 'Knowledge'
      end
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
      within("#sidebar-menu") do
        click_on 'Knowledge'
      end
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

      expect(page).to have_content 'Link is not a valid URL'

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

    it 'check the settings page' do
      within("#sidebar-menu") do
        click_on 'Settings'
      end
      expect(page).to have_content 'Free plan is active.'
      expect(page).to have_content 'The 500 button clicks in total are included — 500 clicks left.'
      click_on '+ Add new address'

      using_wait_time 3 do
        expect(page).to have_content 'Domain Address'
      end

      within("#new_project_path_form") do
        fill_in 'Address', with: 'd'
      end

      click_on 'Add Domain'

      expect(page).to have_content 'Value is not a valid URL'

      within("#new_project_path_form") do
        fill_in 'Address', with: 'http://localhost.com/blog'
      end
      click_on 'Add Domain'
      expect(page).to have_content 'http://localhost.com/blog'
    end

    context 'with existing page and article' do
      include ActionView::RecordIdentifier

      let!(:article) do
        article = project.articles.create!(
          article_hash: '123',
          title: 'Random article title',
          article: 'Article content',
          tokens_count: 1000
        )
        article
      end
      let!(:project_page) do
        project.pages.create!(url: 'http://localhost.com/new-year', url_hash: '123', project_article_id: article.id)
      end

      it 'check the pages items on the pages page' do
        click_on 'Pages'
        # sleep(0.5)

        expect(page).to have_content 'Summer will appear on all the pages from your domain link'
        click_on 'Random article title'

        expect(page).to have_current_path(project_page_path(project, project_page))
        expect(page).to have_content(article.title)
        expect(page).to have_content(project_page.url)

        expect(page).to have_button 'Build summary'

        llm_call = article.summary_llm_calls.create!(llm: 'gpt-4o-mini', project:, input: 'A.', output: 'B.')
        article.update!(summary_status: 'completed', summary_llm_call: llm_call)

        refresh

        expect(page).to have_content llm_call.output
        expect(page).to have_button 'Rewrite'
      end
    end
  end
end
