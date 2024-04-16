# frozen_string_literal: true
RSpec.describe Api::V1::Pages::SummaryController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let!(:user) { create_default_user }
  let!(:project) do
    user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
  end
  let!(:api_key) { project.uuid }
  let!(:article_url) { 'http://localhost.com/new-year-celebrations' }

  let!(:project_article) do
    project.articles.create!(
      article_hash: '123',
      title: 'Article title',
      article: 'Article content',
      tokens_count: 1000,
      last_scraped_at: Time.now.utc,
      image_url: 'http://localhost.com/image.jpg',
      summary_status: 'wait',
      products_status: 'wait'
    )
  end

  let!(:project_page) do
    project.pages.create!(url: article_url, url_hash: '123', project_article_id: project_article.id)
  end

  before do
    request.headers['origin'] = 'http://localhost.com'
    request.headers['Api-Key'] = api_key

    allow(controller).to receive(:project_page).and_return(project_page)
    allow(controller).to receive(:extract_data_from_id_param)
  end

  describe 'GET /stream' do
    render_views
    context 'when a summary already exists' do
      before do
        project_article.summary_status_completed!
        call_id = project_article.summary_llm_calls.create!(llm: 'gpt3.5', project:, input: 'A.', output: 'B. C')
        project_article.update!(summary_llm_call: call_id)
      end

      it 'returns valid result' do
        get :stream, params: { page_id: 'random', format: :json }
        expect(response.headers['Content-Type']).to eq('text/event-stream')
        expect(response.body).to include("data: B. C\n\n")
      end
    end

    context 'when a summary does not exist yet' do
      include_context 'with gpt requests'
      it 'returns valid result' do
        stub_gpt_summary_request([' 123', '456...', ''])

        get :stream, params: { page_id: 'random', format: :json }
        expect(response.headers['Content-Type']).to eq('text/event-stream')
        expect(response.body).to include("data:  123\n\n")
        expect(response.body).to include("data: 456...\n\n")
      end

      it 'returns error when redis timeout happens' do
        allow(SummarizeArticleJob).to receive(:perform_later)
        allow(controller).to receive(:subscribe_on_channel).and_raise(Redis::TimeoutError)

        get :stream, params: { page_id: 'random', format: :json }
        expect(response.headers['Content-Type']).to eq('text/event-stream')
        expect(response.body).to include("data: --ERROR--\n\n")
      end
    end
  end
end
