# frozen_string_literal: true
RSpec.describe Api::V1::Pages::ProductsController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let!(:project) do
    user = create_default_user
    user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
  end

  let(:article) do
    project.articles.create!(
      article_hash: '123',
      title: 'Article title',
      article: 'Article content',
      tokens_count: 1000,
      summary_status: 'wait',
      products_status: 'wait'
    )
  end

  let!(:project_page) do
    call_id = article.summary_llm_calls.create!(llm: 'gpt-4o-mini', project:, input: 'A.', output: 'B.')
    article.update!(summary_llm_call: call_id)
    project.pages.create!(
      url: 'http://localhost.com/new-year',
      url_hash: '123',
      project_article_id: article.id,
    )
  end

  before do
    request.headers['origin'] = 'http://localhost.com'
    request.headers['Api-Key'] = project.uuid

    allow(controller).to receive(:project_page).and_return(project_page)
    allow(controller).to receive(:extract_data_from_id_param)
  end

  describe 'GET /show' do
    include_context 'with gpt requests'
    render_views

    it 'calls GPT and returns a suitable product' do
      allow(ProjectProductLinkScrapeJob).to receive(:perform_later).and_return(true)

      p1 = project.products.create!(name: 'B', link: 'http://a.com/a', description: 'Hey')
      p2 = project.products.create!(name: 'SW', link: 'http://a.com/b', description: 'Hi')

      stub_gpt_products_request(
        get_gpt_products_response_json_example(
          "[\n    {\"id\": #{p1.id}, \"related\": false},\n    {\"id\": #{p2.id}, \"related\": true}\n]",
        ),
      )

      page_id = BasicEncrypting.encode_array([project_page.id, Time.now.utc.to_i + 1000])
      get :show, params: { page_id:, format: :json }
      expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        'services' => [
          { 'icon' => nil, 'link' => 'http://a.com/b', 'name' => 'SW', 'uuid' => p2.uuid },
        ],
      )
    end

    it 'returns empty result as there is no suitable products' do
      allow(FindProductsInSummaryJob).to receive(:perform_later)

      page_id = BasicEncrypting.encode_array([project_page.id, Time.now.utc.to_i + 1000])
      get :show, params: { page_id:, format: :json }
      expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include('services' => [])
    end

    it 'returns some products without calling the GPT' do
      allow(ProjectProductLinkScrapeJob).to receive(:perform_later).and_return(true)

      p1 = project.products.create!(name: 'B', link: 'http://a.com/a', description: 'Hey')
      p2 = project.products.create!(name: 'SW', link: 'http://a.com/b', description: 'Hi')

      article.related_products = [p2, p1]
      article.products_status_completed!

      page_id = BasicEncrypting.encode_array([project_page.id, Time.now.utc.to_i + 1000])
      get :show, params: { page_id:, format: :json }
      expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include(
        'services' => [
          { 'icon' => nil, 'link' => 'http://a.com/b', 'name' => 'SW', 'uuid' => p2.uuid },
          { 'icon' => nil, 'link' => 'http://a.com/a', 'name' => 'B', 'uuid' => p1.uuid },
        ],
      )
    end

    it 'returns an empty request as there is no customer products' do
      page_id = BasicEncrypting.encode_array([project_page.id, Time.now.utc.to_i + 1000])
      get :show, params: { page_id:, format: :json }
      expect(response.headers['Content-Type']).to eq('application/json; charset=utf-8')
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to include('services' => [])
    end
  end
end
