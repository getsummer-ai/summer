# frozen_string_literal: true
RSpec.describe Api::V1::ButtonController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let!(:user) { create_default_user }
  let!(:project) do
    user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
  end
  let!(:api_key) { project.uuid }
  let!(:article_url) { 'http://localhost:3000/new-year-celebrations' }

  before { request.headers['Api-Key'] = api_key }

  describe 'GET /settings' do
    context 'when api key is wrong' do
      let(:api_key) { 'random-key' }

      it 'returns invalid Api-Key response' do
        get(:settings)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to eq "{\"message\":\"Invalid Api-Key\"}"
      end
    end

    it 'returns incorrect domain response when there is no origin or referrer header' do
      get(:settings)
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to eq "{\"code\":\"wrong_domain\",\"message\":\"Incorrect domain\"}"
    end

    it 'returns ok when an origin header includes the www subdomain' do
      request.headers['origin'] = 'http://www.localhost.com'
      get(:settings)
      expect(response).to have_http_status(:ok)
    end

    it 'returns ok when a project\'s domain includes the www subdomain' do
      project.update!(domain: 'www.localhost.com')
      request.headers['origin'] = 'http://localhost.com'
      get(:settings)
      expect(response).to have_http_status(:ok)
    end

    it 'returns ok when a project\'s domain_alias includes the www subdomain' do
      project.update!(domain: 'random.com')
      project.update!(domain_alias: 'www.localhost.com')
      request.headers['origin'] = 'http://localhost.com'
      get(:settings)
      expect(response).to have_http_status(:ok)
    end

    it 'returns ok when there is only a referer header' do
      request.headers['referer'] = 'https://www.localhost.com/'
      get(:settings)
      expect(response).to have_http_status(:ok)
    end

    context 'when the domain check passes' do
      render_views
      before { request.headers['origin'] = 'http://localhost.com' }

      it 'returns response successfully' do
        get(:settings)
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          path: be_a(String).and(include('/libs/app.')),
          settings: {
            lang: 'en',
            appearance: {
              button_theme: 'black',
              frame_theme: 'white',
              z_index: 10_000,
            },
            paths: [],
            features: {
              suggestion: true,
              subscription: true,
            },
          },
        )
      end

      it 'returns response successfully when project settings are changed' do
        project.update!(
          settings_attributes: {
            feature_subscription_attributes: {
              enabled: false,
            },
            feature_suggestion_attributes: {
              enabled: false,
            },
          },
          paths: %w[/path1 /path2],
        )

        get(:settings)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          path: be_a(String).and(include('/libs/app.')),
          settings: {
            lang: 'en',
            appearance: {
              button_theme: 'black',
              frame_theme: 'white',
              z_index: 10_000,
            },
            paths: %w[/path1 /path2],
            features: {
              suggestion: false,
              subscription: false,
            },
          },
        )
      end
    end
  end

  describe 'POST /init' do
    subject(:post_request) { post(:init, body: { s: article_url }.to_json, as: :json) }

    it 'returns Invalid Api-Key response when api key is wrong' do
      request.headers['Api-Key'] = project.id
      post_request
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to eq "{\"message\":\"Invalid Api-Key\"}"
    end

    it 'returns Incorrect domain response' do
      post_request
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to eq "{\"code\":\"wrong_domain\",\"message\":\"Incorrect domain\"}"
    end

    describe 'when the main API filters are passed' do
      render_views
      before do
        project.update_attribute!(:domain, 'localhost')
        request.headers['origin'] = 'http://localhost'
        stub_request(:get, 'http://localhost:3000/new-year-celebrations').to_return(
          body: Rails.root.join('spec/fixtures/html/new-year-celebrations.html').read,
          headers: {
            'Content-Type' => 'text/html',
          },
        )
      end

      def check_response_for_successful_request
        arr = [ProjectArticle.count, ProjectPage.count, ProjectArticle.first.pages.count]
        expect(arr).to eq [1, 1, 1]
        article = project.articles.first
        expect(article.tokens_count).to be_a(Integer)
        expect(article.title).to eq 'New Year celebrations'
        expect(article.summary_status).to eq 'wait'
        expect(article.products_status).to eq 'wait'

        page = article.pages.first
        expect(page.url).to eq 'http://localhost:3000/new-year-celebrations'
        expect(page.is_accessible).to be true

        body = response.parsed_body
        expect(body['article']['page_id']).to be_a(String)
        expect(body['article']['title']).to eq 'New Year celebrations'
      end

      it 'returns response successfully' do
        post_request
        expect(response).to have_http_status(:ok)
        check_response_for_successful_request
      end

      it 'returns response successfully when the only domain_alias matches the domain of the url' do
        project.update_attribute! :domain, 'random.com'
        project.update_attribute! :domain_alias, 'localhost'
        post_request
        expect(response).to have_http_status(:ok)
        check_response_for_successful_request
      end

      it 'returns 400 when URL is not in a body' do
        post(:init, body: { s: '' }.to_json, as: :json)
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq ''
      end

      it 'returns 400 if page load fails' do
        stub_request(:get, 'http://localhost:3000/new-year-celebrations').to_raise(StandardError)
        post_request
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to eq ''
      end

      it 'returns existing article without extra load the URL.' do
        form = ProjectArticleForm.new(project, article_url)
        form.find_or_create

        stub_request(:get, 'http://localhost:3000/new-year-celebrations').to_raise(StandardError)

        post_request
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to eq ''

        encrypted_page_id = response.parsed_body['article']['page_id']
        expect(encrypted_page_id).to be_a(String)
        expect(form.project_page.id).to eq BasicEncrypting.decode_array(encrypted_page_id, 2)[0]
      end

      it 'returns empty body when the page is disabled' do
        form = ProjectArticleForm.new(project, article_url)
        form.find_or_create
        form.project_page.update!(is_accessible: false)

        post_request
        expect(response).to have_http_status(:no_content)
        expect(response.body).to eq ''
      end

      it 'returns empty body if a summary was skipped' do
        article = ProjectArticleForm.new(project, article_url).find_or_create
        article.summary_status_skipped!

        post_request
        expect(response).to have_http_status(:no_content)
        expect(response.body).to eq ''
      end
    end
  end
end
