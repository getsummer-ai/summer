# frozen_string_literal: true
RSpec.describe Api::V1::Pages::UsersController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let!(:project) do
    user = create_default_user
    user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
  end

  let!(:project_page) do
    article = project.articles.create!(
      article_hash: '123',
      title: 'Article title',
      article: 'Article content',
      tokens_count: 1000
    )
    project.pages.create!(url: 'http://localhost.com/new-year', url_hash: '123', project_article_id: article.id)
  end

  before do
    request.headers['origin'] = 'http://localhost.com'
    request.headers['Api-Key'] = project.uuid

    allow(controller).to receive(:project_page).and_return(project_page)
    allow(controller).to receive(:extract_data_from_id_param)
  end

  describe 'GET /subscribe' do
    render_views
    it 'returns ok when an email address is valid' do
      get :subscribe, params: { page_id: 'random-encrypted-data', email: 'example@example.com', format: :json }
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(response).to have_http_status(:ok)
    end

    it 'returns unprocessable_entity when an email address is invalid' do
      get :subscribe, params: { page_id: 'random-encrypted-data', email: '@example.com', format: :json }
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns unprocessable_entity when page_id is in DB already is invalid' do
      encrypted_page_id = 'random-encrypted-data'
      project.user_emails.create!(encrypted_page_id:, email: 'nevermind@google.com', project_page:)

      get :subscribe, params: { page_id: encrypted_page_id, email: 'ok@example.com', format: :json }

      expect(response.headers['Content-Type']).to eq('application/json')
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns ok when an email already exists' do
      encrypted_page_id = 'random-encrypted-page-1'
      project.user_emails.create!(encrypted_page_id:, email: 'example@example.com', project_page:)

      get :subscribe, params: { page_id: 'random-encrypted-page-2', email: 'example@example.com', format: :json }
      expect(response.headers['Content-Type']).to eq('application/json')
      expect(response).to have_http_status(:ok)
    end
  end
end
