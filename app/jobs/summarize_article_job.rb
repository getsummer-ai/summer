# frozen_string_literal: true
class SummarizeArticleJob < ApplicationJob
  queue_as :default
  # retry_on StandardError, attempts: 2
  PREFIX =
    "Below you will find an article, please make a summary for me. Please follow the following instruction:
              — Don't include things that look like promotion;
              — Keep the same language as in the original article;
              — Make structure clear and easy, use bullet points;
              Please, make it good, it is extremely important for me: \n\t"
  
  LLM_MODEL_MAPPING = {
    gpt3: 'gpt-3.5-turbo',
    gpt4: 'gpt-4',
  }.freeze

  def self.perform(*args)
    new.perform(*args)
  end

  # @param [Integer] id
  def perform(id, as_stream: true)
    # @type [ProjectArticle]
    model = ProjectArticle.includes(:project).find(id)
    model.start_tracking(source: 'SummarizeArticleJob')
    model.status_processing!
    llm = model.project.default_llm
    model.llm = llm
    channel_name = model.redis_name
    message = PREFIX + model.article

    begin
      res = nil
      stream_func = as_stream ? stream_receiver(channel_name) : nil
      time = measure { res = ask_gpt_to_summarize(message, llm, stream_func) }
      summary = as_stream ? redis.get(channel_name) : res&.dig('choices', 0, 'message', 'content')
      model.update!({
        service_info: { time:, response: res },
        status: :summarized,
        summary:,
        summarized_at: Time.zone.now.utc,
      })
    rescue StandardError => e
      model.update!(service_info: { error: e.to_s, backtrace: e.backtrace&.grep(%r{/app/}) }, status: :error)
      raise
    ensure
      if as_stream
        redis.publish(channel_name, 'done')
        redis.del(channel_name)
        redis.quit
      end
    end
  end

  protected

  def measure
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ending - starting
  end

  # @param [String] message
  def ask_gpt_to_summarize(message, llm, stream = nil)
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: get_model_name(llm),
        messages: [{ role: 'user', content: message }],
        stream:
      },
    )
    return nil if stream.present?
    response
  end

  # @param [String] channel_name
  def stream_receiver(channel_name)
    proc do |chunk, _bytesize|
      content = chunk.dig("choices", 0, "delta", "content")
      puts content
      redis.set(channel_name, (redis.get(channel_name).presence || '') + content.to_s)
      redis.publish(channel_name, content)
    end
  end

  def get_model_name(llm)
    name = LLM_MODEL_MAPPING[llm.to_sym]
    raise("Unknown LLM model: #{llm}") if name.nil?
    name
  end

  def redis
    @redis ||= Redis.new
  end
end
