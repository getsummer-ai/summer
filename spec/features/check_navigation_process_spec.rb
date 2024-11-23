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

        expect(page).to have_content 'Summer will appear on all the pages from your domain link'
        click_on 'Random article title'

        expect(page).to have_current_path(project_page_path(project, project_page))
        expect(page).to have_content(article.title)
        expect(page).to have_content(project_page.url)

        # Check the turbo frame section
        within("#page-page") do
          expect(page).to have_content 'Statistic'
        end

        # Check the turbo frame section
        within("#page-summary") do
          expect(page).to have_content 'Summary'
          expect(page).not_to have_content 'Relevant products'
          expect(page).not_to have_button 'Preview'
          expect(page).to have_button 'Build summary'
        end

        llm_call = article.summary_llm_calls.create!(llm: 'gpt-4o-mini', project:, input: 'A.', output: 'B.')
        article.update!(summary_status: 'completed', summary_llm_call: llm_call)

        refresh

        # Check the turbo frame section
        within("#page-summary") do
          expect(page).to have_content llm_call.output
          expect(page).to have_button 'Rewrite'
          expect(page).to have_button 'Preview'

          expect(page).to have_content 'Relevant products'
          expect(page).to have_content "You don't have any products to link to the summary yet"
          expect(page).to have_link 'Go and add products'

          click_on 'Preview'
        end

        # Check the Summer modal preview
        within("div.dialog-modal") do
          expect(page).to have_content article.title
          expect(page).to have_content llm_call.output
          expect(page).to have_content 'Subscribe on weekly summaries:'
          expect(page).to have_content 'Powered by'
        end

        send_keys :escape

        #
        # Create a product and link it to the article to check the products section
        #
        product = project.products.create!(name: 'Test product', link: 'http://a.com/a', description: 'Op 12345678')
        article.related_products << product

        refresh

        within("#page-summary") do
          expect(page).to have_content 'Relevant products'
          expect(page).to have_content "Test product"

          click_on 'Preview'
        end

        # Check the Summer modal preview
        within("div.dialog-modal") do
          expect(page).to have_content article.title
          expect(page).to have_content llm_call.output
          expect(page).to have_content 'Test product'
        end

        send_keys :escape

        within('#table_project_article_product') do
          find("input[type='checkbox']").set(false)
        end

        expect(page).to have_content '"Test product" product is disabled'

        within("#page-summary") do
          click_on 'Preview'

          within("div.dialog-modal") do
            expect(page).to have_content article.title
            expect(page).to have_content llm_call.output
            expect(page).not_to have_content 'Test product'
          end
        end
      end
    end
  end
end
