# frozen_string_literal: true
class SummarizeArticleJob
  class SummarizeArticleWrapper
    # @return [ProjectArticle]
    attr_reader :model

    PREFIX =
      "Below you will find an article, please make a summary for me. Please follow the following instruction:
              — %{guidelines};
              — Don't include things that look like promotion;
              — Keep the same language as in the original article;
              — Make structure clear and easy, use bullet points;
              Please, make it good, it is extremely important for me: \n\t"

    LLM_MODEL_MAPPING = { gpt3: 'gpt-3.5-turbo', gpt4: 'gpt-4' }.freeze

    # @param [ProjectArticle] model
    # @param [Symbol] llm
    def initialize(model, llm)
      @model = model
      @llm = LLM_MODEL_MAPPING[llm.to_sym]
      raise("Unknown LLM model: #{llm}") if @llm.nil?
      @redis_wrapper = SummarizeRedisWrapper.new(@model, Redis.new)
    end

    def self.find(id)

      new()
    end

    def summarize
      @model.start_tracking(source: 'SummarizeArticleJob')
      @model.status_summary_processing!
      time = measure { ask_gpt_to_summarize }
      success!({ time: })
    rescue StandardError => e
      error! e
      raise
    ensure
      @redis_wrapper.quit
    end

    private

    def ask_gpt_to_summarize
      client = OpenAI::Client.new
      client.chat(
        parameters: {
          model: @llm,
          messages: [{ role: 'user', content: input }],
          stream: @redis_wrapper.stream_function,
        },
      )
    end

    # @param [Hash] info
    def success!(info)
      summary = @redis_wrapper.result
      in_tokens_count = LanguageModelTools.estimate_max_tokens(input)
      out_tokens_count = LanguageModelTools.estimate_max_tokens(summary)

      ProjectArticle.transaction do
        @model.update!(info_attributes: { summary: info }, status_summary: :completed)
        @model.summaries.create!(in_tokens_count:, out_tokens_count:, llm: @llm, summary:, info:)
      end
    end

    # @param [StandardError] error
    def error!(error)
      info_summary = { error: error.to_s, backtrace: error.backtrace&.grep(%r{/app/})&.join("\n") }
      @model.update!(info_attributes: { summary: info_summary }, status_summary: :error)
    end

    def input
      @input ||= format(PREFIX, guidelines: @model.project.guidelines) + @model.article
    end

    def measure
      @model.log_info('OpenAI - Begins', type: 'summarize')
      starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      time = ending - starting
      @model.log_info('OpenAI - Ends Successfully', type: 'summarize', time:)
      time
    rescue StandardError => e
      @model.log_info('OpenAI - Ends Unsuccessfully', type: 'summarize', error: e.to_s)
      raise
    end
  end
end
