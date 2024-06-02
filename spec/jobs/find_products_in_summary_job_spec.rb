# frozen_string_literal: true

describe FindProductsInSummaryJob do
  include SpecTestHelper

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }
  let!(:article) do
    article = project.articles.create!(article_hash: '354', article: 'On the...')
    call_id = article.summary_llm_calls.create!(llm: 'gpt3.5', project:, input: 'A.', output: 'B.')
    article.update!(summary_llm_call: call_id)
    article
  end

  describe '#perform' do
    it 'executes the service properly' do
      service = instance_double(FindProductsInSummaryService)
      allow(FindProductsInSummaryService).to receive(:new).with(model: article).and_return(service)
      allow(service).to receive(:summarize).and_return(true)

      described_class.perform(article.id)

      expect(service).to have_received(:summarize)
    end
  end
end
