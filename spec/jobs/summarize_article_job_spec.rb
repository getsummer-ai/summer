# frozen_string_literal: true

describe SummarizeArticleJob do
  include SpecTestHelper

  let!(:article) do
    user = create_default_user
    project = user.projects.create(name: 'Test Project', protocol: 'http', domain: 'test.com')
    article = project.articles.create(
      article_hash: '354fdebd51e8fbdfd462dd604e00224b',
      article: 'On the night of 31 December and the morning of 1 January, people in many countries all over...',
      title: 'New Year celebrations',
      summary_status: 'wait',
      tokens_count: 942,
    )
    article
  end

  describe '#perform' do
    it 'executes the service properly' do
      service = instance_double(SummarizeArticleService)
      allow(SummarizeArticleService).to receive(:new).with(
        model: article,
        llm: article.project.default_llm,
        guidelines: article.project.guidelines
      ).and_return(service)
      allow(service).to receive(:summarize).and_return(true)

      described_class.perform(article.id)

      expect(service).to have_received(:summarize)
    end
  end
end
