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

        using_wait_time 3 do
          expect(page).to have_content 'Dismiss'
        end

        within('#modal') do
          expect(page).to have_field(with: article.title)

          within_table("table-page-statistics") do
            expect(page).to have_no_content 'Summary'
            expect(page).to have_no_content 'Show'
          end
        end


        llm_call = article.summary_llm_calls.create!(llm: 'gpt3.5', project:, input: 'A.', output: 'B.')
        article.update!(summary_status: 'completed', summary_llm_call: llm_call)

        refresh

        using_wait_time 3 do
          expect(page).to have_content 'Dismiss'
        end

        within('#modal') do
          expect(page).to have_field(with: article.title)

          within_table("table-page-statistics") do
            expect(page).to have_content 'Summary'
            expect(page).to have_content 'Show'
          end

          click_on 'Show'

          within("##{dom_id(project_page, :summary)}") do
            expect(page).to have_content llm_call.output
          end

          expect(page).to have_content 'Back'
          expect(page).to have_button 'Refresh summary'
          click_on 'Back'

          expect(page).to have_button 'Turn off this page'
          click_on 'Turn off this page'
        end

        expect(page).to have_content 'URL was successfully updated'

        click_on 'Dismiss'
        expect(page).to have_no_content 'Symbols on the page'
      end
    end
  end
end
