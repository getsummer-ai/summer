# frozen_string_literal: true

describe FindProductsInSummaryJob do
  include SpecTestHelper

  subject { described_class.perform(article.id) }

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }
  let!(:article) do
    article = project.articles.create!(article_hash: '354', article: 'On the...')
    call_id = article.summary_llm_calls.create!(llm: 'gpt3.5', project:, input: 'A.', output: 'B.')
    article.update!(summary_llm_call: call_id)
    article
  end

  let(:product_1) do
    project.products.create!(name: 'B', link: 'http://a.com/a', description: 'Hey')
  end
  let(:product_2) { project.products.create!(name: 'S', link: 'http://a.com/b', description: 'Hi') }

  let(:payload) do
    "[\n    {\"id\": #{product_1.id}, \"related\": true},\n    {\"id\": #{product_2.id}, \"related\": false}\n]"
  end

  let(:llm_response) do
    {
      id: 'chatcmpl-9BtI0AlbEooZON0ytK20CxPcAW5Tj',
      model: 'gpt-3.5-turbo-0125',
      usage: {
        total_tokens: 288,
        prompt_tokens: 262,
        completion_tokens: 26,
      },
      object: 'chat.completion',
      choices: [
        {
          index: 0,
          message: {
            role: 'assistant',
            content: payload,
          },
          logprobs: nil,
          finish_reason: 'stop',
        },
      ],
      created: 1_712_621_168,
      system_fingerprint: 'fp_b28b39ffa8',
    }.to_json
  end

  before do
    allow(ProjectProductLinkScrapeJob).to receive(:perform_later).and_return(true)

    stub_request(:post, %r{/chat/completions}).to_return(
      body: llm_response,
      headers: {
        'Content-Type' => 'application/json',
      },
    )
  end

  describe '#perform' do
    it 'works well' do
      expect { subject }.to change { article.reload.products_status }.from('wait').to('completed')
      expect(article.info.products['time']).to be_a(Float)
      expect(article.summary_llm_calls.count).to eq 1
      expect(article.products_llm_calls.count).to eq 1
      expect(article.products_llm_call.output).to eq payload
      expect(article.events.order(id: :asc).pluck(:source)).to eq [
           'FindProductsInSummaryService', # start_tracking - status changing
           'OpenAI - Begins',
           'OpenAI - Ends Successfully',
           'FindProductsInSummaryService', # start_tracking - row updating
         ]
    end

    context 'when a wrong json is returned' do
      let(:llm_response) { 'wrong' }

      it 'throws error if the response is incorrect' do
        expect { subject }.to raise_error(Faraday::ParsingError)
      end
    end

    context 'when there is no useful data in a response' do
      let(:llm_response) { { a: 'a' }.to_json }

      it 'throws error if the response is incorrect' do
        expect { subject }.to raise_error(RuntimeError, 'Output is empty {"a":"a"}')
      end
    end
  end
end
