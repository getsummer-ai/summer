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

  LLM_MODEL_MAPPING = { gpt3: 'gpt-3.5-turbo', gpt4: 'gpt-4' }.freeze

  def self.perform(*args)
    new.perform(*args)
  end

  # @param [Integer] id
  def perform(id)
    model = find_article_and_start_tracking(id)
    channel_name = model.redis_name
    redis = Redis.new
    begin
      time =
        summarize_article_and_get_time(
          redis,
          channel_name,
          model.article,
          model.project.default_llm,
        )
      update_model_with_success_info! model, time, redis.get(channel_name)
    rescue StandardError => e
      update_model_with_error_info! model, e
      raise
    ensure
      redis&.publish(channel_name, 'done')
      redis&.del(channel_name)
      redis&.quit
    end
  end

  protected

  # @param [ProjectArticle] model
  # @param [Complex] time
  # @param [String] summary
  def update_model_with_success_info!(model, time, summary)
    tokens_count = LanguageModelTools.estimate_max_tokens(summary)
    created_at = Time.now.utc
    info = { summary: { time: } }
    model.update!({ info:, status_summary: :completed })

    model.project_article_summaries.create!(
      tokens_count:,
      llm: model.project.default_llm,
      created_at:,
      summary:,
      info: info[:summary],
    )
  end

  # @param [ProjectArticle] model
  # @param [StandardError] error
  def update_model_with_error_info!(model, error)
    model.info_summary = { error: error.to_s, backtrace: error.backtrace&.grep(%r{/app/})&.join("\n") }
    model.status_summary = :error
    model.save!
  end

  # @param [Redis] redis
  # @param [String] channel_name
  # @param [String] article
  # @param [Symbol] llm
  # @return [Complex]
  def summarize_article_and_get_time(redis, channel_name, article, llm)
    stream_func =
      proc do |chunk, _bytesize|
        content = chunk.dig('choices', 0, 'delta', 'content')
        # Rails.logger.debug content
        redis.append(channel_name, content)
        redis.publish(channel_name, content)
      end
    measure { ask_gpt_to_summarize(PREFIX + article, llm, stream_func) }
  end

  # @return [ProjectArticle]
  def find_article_and_start_tracking(id)
    model = ProjectArticle.includes(:project).find(id)
    model.start_tracking(source: 'SummarizeArticleJob')
    model.status_summary_processing!
    model
  end

  def measure
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ending - starting
  end

  # @param [String] message
  # @param [Symbol] llm
  # @param [Proc] stream
  def ask_gpt_to_summarize(message, llm, stream)
    client = OpenAI::Client.new
    client.chat(
      parameters: {
        model: get_model_name(llm),
        messages: [{ role: 'user', content: message }],
        stream:,
      },
    )
  end

  def get_model_name(llm)
    name = LLM_MODEL_MAPPING[llm.to_sym]
    raise("Unknown LLM model: #{llm}") if name.nil?
    name
  end
end
