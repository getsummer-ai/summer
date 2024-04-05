# frozen_string_literal: true
RSpec.describe Api::V1::ButtonController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let!(:user) do
    User.create(
      email: 'admin@test.ru',
      password: '12345678',
      password_confirmation: '12345678',
      confirmed_at: Time.zone.now,
    )
  end
  let!(:project) { user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project') }
  let!(:api_key) { project.uuid }

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

    it 'returns incorrect domain response' do
      get(:settings)
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to eq "{\"code\":\"wrong_domain\",\"message\":\"Incorrect domain\"}"
    end

    context 'when http_status is 200' do
      render_views

      it 'returns response successfully' do
        request.headers['origin'] = 'http://localhost.com'
        get(:settings)
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          path: be_a(String).and(include('/libs/app.umd.js')),
          settings: {
            appearance: { button_radius: 'xl', button_theme: 'white', frame_theme: 'white' },
            paths: [], features: { suggestion: true, subscription: true }
          }            
        )
      end

      it 'returns response successfully when project settings are changed' do
        project.update!(
          settings_attributes: {
            feature_subscription_attributes: { enabled: false }, feature_suggestion_attributes: { enabled: false }
          },
          paths: %w[/path1 /path2]
        )
        request.headers['origin'] = 'http://localhost.com'

        get(:settings)

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include(
          path: be_a(String).and(include('/libs/app.umd.js')),
          settings: {
            appearance: { button_radius: 'xl', button_theme: 'white', frame_theme: 'white' },
            paths: %w[/path1 /path2], features: { suggestion: false, subscription: false }
          }
        )
      end
    end
  end

  describe 'POST /init' do
    subject(:post_request) do
      post(:init, body: { s: 'http://localhost:3000/new-year-celebrations' }.to_json, as: :json)
    end

    context 'when api key is wrong' do
      let(:api_key) { project.id }

      it 'returns Invalid Api-Key response' do
        post_request
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to eq "{\"message\":\"Invalid Api-Key\"}"
      end
    end

    it 'returns Incorrect domain response' do
      post_request
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to eq "{\"code\":\"wrong_domain\",\"message\":\"Incorrect domain\"}"
    end

    describe 'when http_status is 200' do
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

      it 'saves parsed data in database' do
        post_request
        expect(response).to have_http_status(:ok)
        expect([ProjectArticle.count, ProjectPage.count, ProjectArticle.first.pages.count]).to eq [1,1,1]
        article = project.articles.first
        expect(article.tokens_count).to be_a(Integer)
        expect(article.title).to eq 'New Year celebrations'
        expect(article.summary_status).to eq 'wait'
        expect(article.products_status).to eq 'wait'

        page = project.pages.first
        expect(page.url).to eq 'http://localhost:3000/new-year-celebrations'
        expect(page.is_accessible).to be true
      end

      it 'returns response successfully' do
        post_request
        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['article']['page_id']).to be_a(String)
        expect(body['article']['title']).to eq 'New Year celebrations'
      end
    end
  end
end
