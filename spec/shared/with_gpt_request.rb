# frozen_string_literal: true
RSpec.shared_context 'with gpt requests' do
  # stub_request(:post, %r{/chat/completions}).to_return(
  #   body: "event: test\nid: 1\ndata: #{{ choices: [{ delta: { content: " 123" } }] }.to_json}\n\n" \
  #   "event: test\nid: 2\ndata: #{{ choices: [{ delta: { content: "456..." } }] }.to_json}\n\n" \
  #   "event: test\nid: 2\ndata: #{{ choices: [{ delta: { content: "" } }] }.to_json}\n\n" \
  #   "event: test\nid: 2\ndata: [DONE]\n\n",
  #   headers: { 'Content-Type' => 'text/event-stream' }
  # )
  def stub_gpt_summary_request(messages = [])
    body =
      messages.map.with_index do |message, index|
        "event: test\nid: #{index + 1}\ndata: #{{ choices: [{ delta: { content: message } }] }.to_json}\n\n"
      end

    body << "event: test\nid: #{messages.size + 1}\ndata: [DONE]\n\n"

    stub_request(:post, %r{/chat/completions}).to_return(
      body: body.join,
      headers: {
        'Content-Type' => 'text/event-stream',
      },
    )
  end

  def stub_gpt_products_request(body_json = nil)
    stub_request(:post, %r{/chat/completions}).to_return(
      body: body_json.presence || generate_gpt_products_response_body,
      headers: {
        'Content-Type' => 'application/json',
      },
    )
  end

  def get_gpt_products_response_json_example(content = nil)
    {
      id: 'chatcmpl-9BtI0AlbEooZON0ytK20CxPcAW5Tj',
      model: 'gpt-4o-mini',
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
            content:
              content ||
                "[\n    {\"id\": 1, \"related\": true},\n    {\"id\": 2, \"related\": false}\n]",
          },
          logprobs: nil,
          finish_reason: 'stop',
        },
      ],
      created: 1_712_621_168,
      system_fingerprint: 'fp_b28b39ffa8',
    }.to_json
  end
end
