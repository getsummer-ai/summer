# frozen_string_literal: true

describe SummarizeArticleJob do
  subject { described_class.perform(article.id) }

  let(:openai_client) { double }
  let(:openai_response) do
    {
      id: 'chatcmpl-8qV2NLOihOWZGWfbM6ON0FleXHYKf',
      model: 'gpt-3.5-turbo-0613',
      usage: {
        total_tokens: 1014,
        prompt_tokens: 880,
        completion_tokens: 134,
      },
      object: 'chat.completion',
      choices: [
        {
          index: 0,
          message: {
            role: 'assistant',
            content:
              "- New Year celebrations have been happening for thousands of years \n"
          },
          logprobs: nil,
          finish_reason: 'stop',
        },
      ],
      created: 1_707_523_055,
      system_fingerprint: nil,
    }
  end
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
      tokens_count: 942,
    )
    article
  end

  before do
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
    allow(openai_client).to receive(:chat).and_return(openai_response)
  end

  describe '#perform' do
    it 'works well' do
      expect { subject }.to change { article.reload.status }.from('in_queue').to('summarized')
      expect(article.service_info['time']).to be_a(Float)
      expect(article.service_info['response']).to eq openai_response.deep_stringify_keys
    end
  end
end
