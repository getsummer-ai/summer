# frozen_string_literal: true

class SummarizeArticleService
  # @return [ProjectArticle]
  attr_reader :model, :guidelines, :llm

  PREFIX =
    "Below you will find an article, please make a summary for me. Please follow the following instruction:\n"+
    "— %{guidelines};\n" +
    "— Don't include things that look like promotion;\n" +
    "— Keep the same language as in the original article;\n" +
    "— Make structure clear and easy, use bullet points;\n" +
    "Please, make it good, it is extremely important for me: \n"

  LLM_MODEL_MAPPING = { gpt3: 'gpt-3.5-turbo', gpt4: 'gpt-4o' }.freeze

  # @param [ProjectArticle] model
  # @param [Symbol] llm
  # @param [String] guidelines
  def initialize(model:, llm:, guidelines:)
    @model = model
    @guidelines = guidelines
    @llm = llm
    @redis_wrapper = RedisWrapper.new(@model, ::RedisFactory.new)
  end

  def summarize
    @model.start_tracking(source: 'SummarizeArticleJob')
    @model.summary_status_processing!
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
    llm_model = LLM_MODEL_MAPPING[llm.to_sym]
    raise("Unknown LLM model: #{llm}") if llm_model.nil?

    client = OpenAI::Client.new
    client.chat(
      parameters: {
        model: llm_model,
        messages: [{ role: 'user', content: input }],
        stream: @redis_wrapper.stream_function,
      },
    )
  end

  # @param [Hash] info
  def success!(info)
    output = @redis_wrapper.result
    ProjectArticle.transaction do
      call =
        ProjectLlmCall.save_summary_call!(
          @model,
          in_tokens_count: LanguageModelTools.estimate_max_tokens(input),
          out_tokens_count: LanguageModelTools.estimate_max_tokens(output),
          llm:,
          input:,
          output:,
          info:,
        )
      @model.update!(info_attributes: { summary: info }, summary_status: :completed, summary_llm_call_id: call.id)
    end
  end

  # @param [StandardError] error
  def error!(error)
    info_summary = { error: error.to_s, backtrace: error.backtrace&.grep(%r{/app/})&.join("\n") }
    @model.update!(info_attributes: { summary: info_summary }, summary_status: :error)
  end

  def input
    @input ||= format(PREFIX, guidelines:) + @model.article
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
