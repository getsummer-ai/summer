# frozen_string_literal: true
RSpec.describe Api::V1::Pages::SummaryController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let!(:project) do
    user = create_default_user
    user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
  end

  let!(:project_article) do
    project.articles.create!(
      article_hash: '123',
      title: 'Article title',
      article: 'Article content',
      tokens_count: 1000,
      image_url: 'http://localhost.com/image.jpg',
      summary_status: 'wait',
      products_status: 'wait'
    )
  end

  let!(:project_page) do
    project.pages.create!(url: 'http://localhost.com/page', url_hash: '123', project_article_id: project_article.id)
  end

  before do
    request.headers['origin'] = 'http://localhost.com'
    request.headers['Api-Key'] = project.uuid
  end

  describe 'check filters for GET /stream' do
    it 'returns 400 because of invalid param' do
      get :stream, params: { page_id: 'random', format: 'text/event-stream' }
      expect(response.headers['Content-Type']).to eq('text/html')
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns 410 because of invalid time' do
      page_id = BasicEncrypting.encode_array([project_page.id, Time.now.utc.to_i - 1000])
      get :stream, params: { page_id:, format: 'text/event-stream' }
      expect(response.headers['Content-Type']).to eq('text/html')
      expect(response).to have_http_status(:gone)
    end

    it 'returns error because of invalid page id' do
      page_id = BasicEncrypting.encode_array([9999, Time.now.utc.to_i + 2000])
      get :stream, params: { page_id:, format: 'text/event-stream' }
      expect(response.headers['Content-Type']).to eq('text/event-stream')
      expect(response.body).to include("data: --ERROR--\n\n")
    end

    it 'passes the filter ok because everything is fine' do
      allow(SummarizeArticleJob).to receive(:perform_later)

      page_id = BasicEncrypting.encode_array([project_page.id, Time.now.utc.to_i + 2000])
      get :stream, params: { page_id:, format: 'text/event-stream' }
      expect(response.headers['Content-Type']).to eq('text/event-stream')
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /stream' do
    before do
      allow(controller).to receive(:project_page).and_return(project_page)
      allow(controller).to receive(:extract_data_from_id_param)
    end

    render_views
    context 'when a summary already exists' do
      before do
        project_article.summary_status_completed!
        call_id = project_article.summary_llm_calls.create!(llm: 'gpt-4o-mini', project:, input: 'A.', output: 'B. C')
        project_article.update!(summary_llm_call: call_id)
      end

      it 'returns valid result' do
        get :stream, params: { page_id: 'random', format: 'text/event-stream' }
        expect(response.headers['Content-Type']).to eq('text/event-stream')
        expect(response.body).to include("data: B. C\n\n")
      end

      it 'changes project subscription usage information' do
        subscription = project.subscriptions.create!(
          plan: 'free',
          start_at: project.created_at,
          end_at: '2038-01-01 00:00:00',
          summarize_usage: 0,
          summarize_limit: 30,
        )

        project.update!(subscription:)

        expect { get :stream, params: { page_id: 'random', format: 'text/event-stream' } }.to \
          change { project.reload.subscription.summarize_usage }.by(1)
      end
    end

    context 'when a summary does not exist yet' do
      include_context 'with gpt requests'
      it 'returns valid result' do
        stub_gpt_summary_request([' 123', '456...', ''])

        get :stream, params: { page_id: 'random', format: 'text/event-stream' }
        expect(response.headers['Content-Type']).to eq('text/event-stream')
        expect(response.body).to include("data:  123\n\n")
        expect(response.body).to include("data: 456...\n\n")
      end

      it 'returns error when redis timeout happens' do
        allow(SummarizeArticleJob).to receive(:perform_later)
        allow(controller).to receive(:subscribe_on_channel).and_raise(Redis::TimeoutError)

        get :stream, params: { page_id: 'random', format: 'text/event-stream' }
        expect(response.headers['Content-Type']).to eq('text/event-stream')
        expect(response.body).to include("data: --ERROR--\n\n")
      end
    end
  end
end
