# frozen_string_literal: true

describe SummarizeArticleJob do
  subject { described_class.perform(article.id) }

  let!(:article) do
    user = User.create(
      email: 'admin@test.com',
      password: '12345678',
      password_confirmation: '12345678',
      confirmed_at: Time.zone.now
    )
    project = user.projects.create(name: 'Test Project', domain: 'test.com')
    article = project.project_articles.create(
      article_hash: '354fdebd51e8fbdfd462dd604e00224b',
      article: 'On the night of 31 December and the morning of 1 January, people in many countries all over...',
      title: 'New Year celebrations',
      status: 'in_queue',
      tokens_in_count: 942,
    )
    article
  end

  let(:first_event_stream_message) do
    { choices: [{ delta: { content: " New" } }] }
  end

  let(:second_event_stream_message) do
    { choices: [{ delta: { content: " Year's traditions..." } }] }
  end

  let(:third_event_stream_message) do
    { choices: [{ delta: { content: "" } }] }
  end

  describe '#perform' do
    it 'works well' do
      WebMock.disable_net_connect!
      # We stub request to OPEN AI = OpenAI::Client.new; client.chat
      # @see SummarizeArticleJob#ask_gpt_to_summarize
      stub_request(:post, %r{/chat/completions}).to_return(
        body: "event: test\nid: 1\ndata: #{first_event_stream_message.to_json}\n\n" \
              "event: test\nid: 2\ndata: #{second_event_stream_message.to_json}\n\n" \
              "event: test\nid: 2\ndata: #{third_event_stream_message.to_json}\n\n" \
              "event: test\nid: 2\ndata: [DONE]\n\n",
        headers: { 'Content-Type' => 'text/event-stream' }
      )
      expect { subject }.to change { article.reload.status }.from('in_queue').to('summarized')
      expect(article.service_info['time']).to be_a(Float)
      expect(article.summary).to eq " New Year's traditions..."
      WebMock.allow_net_connect!
    end
  end
end
