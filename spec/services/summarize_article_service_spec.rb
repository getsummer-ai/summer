# frozen_string_literal: true

describe SummarizeArticleService do
  include SpecTestHelper

  subject do
    described_class.new(
    model: article,
    llm: article.project.default_llm,
    guidelines: article.project.guidelines,
    ).summarize
  end

  let!(:article) do
    user = create_default_user
    project = user.projects.create(name: 'Test Project', protocol: 'http', domain: 'test.com')
    article =
      project.articles.create(
        article_hash: '354fdebd51e8fbdfd462dd604e00224b',
        article:
          'On the night of 31 December and the morning of 1 January, people in many countries all over...',
        title: 'New Year celebrations',
        summary_status: 'wait',
        tokens_count: 942,
      )
    article
  end


  let(:first_event_stream_message) { { choices: [{ delta: { content: ' New' } }] } }

  let(:second_event_stream_message) do
    { choices: [{ delta: { content: " Year's traditions..." } }] }
  end

  let(:third_event_stream_message) { { choices: [{ delta: { content: '' } }] } }

  describe '#perform' do
    include_context 'with gpt requests'
    it 'works well' do
      WebMock.disable_net_connect!
      # We stub request to OPEN AI = OpenAI::Client.new; client.chat
      # @see SummarizeArticleJob#ask_gpt_to_summarize
      stub_gpt_summary_request([' New', " Year's traditions...", ''])
      expect { subject }.to change { article.reload.summary_status }.from('wait').to('completed')
      expect(article.info.summary['time']).to be_a(Float)
      expect(article.summary_llm_calls.count).to eq 1
      expect(article.summary_llm_call.output).to eq " New Year's traditions..."
      expect(article.events.order(id: :asc).pluck(:source)).to eq [
           'SummarizeArticleJob',
           'OpenAI - Begins',
           'OpenAI - Ends Successfully',
           'SummarizeArticleJob',
         ]
      WebMock.allow_net_connect!
    end
  end
end
