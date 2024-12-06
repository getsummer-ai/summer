# frozen_string_literal: true

describe FindProductsInSummaryService do
  include SpecTestHelper

  subject { described_class.new(model: article).summarize }

  include_context 'with gpt requests'

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }
  let!(:article) do
    article = project.articles.create!(article_hash: '354', article: 'On the...')
    call_id = article.summary_llm_calls.create!(llm: 'gpt-4o-mini', project:, input: 'A.', output: 'B.')
    article.update!(summary_llm_call: call_id)
    article
  end

  let(:product_1) { project.products.create!(name: 'B', link: 'http://a.com/a', description: 'Hop') }
  let(:product_2) { project.products.create!(name: 'S', link: 'http://a.com/b', description: 'Hey') }
  let(:product_3) { project.products.create!(name: 'L', link: 'http://l.com/l', description: 'la la lay') }

  let(:payload) do
    "[\n    {\"id\": #{product_1.id}, \"related\": true},\n"\
    "{\"id\": #{product_2.id}, \"related\": false}\n]" \
    "{\"id\": #{product_3.id}, \"related\": false}\n]" \
  end

  let(:llm_response) { get_gpt_products_response_json_example(payload) }

  before do
    allow(ProjectProductLinkScrapeJob).to receive(:perform_later).and_return(true)
    stub_gpt_products_request(llm_response)
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

    context 'when payload is json but wrapped with markdown tag' do
      let(:payload) do
        "```json\n[\n{\"id\":#{product_1.id},\"related\":true},\n{\"id\":#{product_2.id},\"related\":false}\n]\n```"
      end

      it 'works well' do
        expect { subject }.to change { article.reload.products_status }.from('wait').to('completed')
        expect(article.info.products['time']).to be_a(Float)
      end
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

    context 'when all the products are related to the article' do
      let(:payload) do
        "[\n    {\"id\": #{product_1.id}, \"related\": true},\n   "\
        "{\"id\": #{product_2.id}, \"related\": true},\n" \
        "{\"id\": #{product_3.id}, \"related\": true}\n]" \
      end

      it 'attaches all of them but makes some products hidden if there are more than two related' do
        expect { subject }.to change { article.reload.products_status }.from('wait').to('completed')
                              .and change { article.reload.related_products.count }.from(0).to(3)
        article.reload.project_article_products.map do |pap|
          expected_is_accessible_value = pap.project_product_id != product_3.id
          expect(pap.is_accessible).to be expected_is_accessible_value
        end
      end
    end
  end
end
