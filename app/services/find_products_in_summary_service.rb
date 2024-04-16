# frozen_string_literal: true

class FindProductsInSummaryService
  # @return [ProjectArticle]
  attr_reader :model, :guidelines, :llm

  PREFIX =
    "I need to understand if the following text " +
    "relates to the products I offer.\n%{article}\n" +
    "Please take a look at the product list: \n"
  POSTFIX = "\nPlease respond as a JSON array, in the following format: [{\"id\": number, \"related\": bool}]\n"

  LLM_MODEL_MAPPING = { gpt3: 'gpt-3.5-turbo', gpt4: 'gpt-4' }.freeze

  # @param [ProjectArticle] model
  # @param [Symbol] llm
  def initialize(model:, llm:)
    @model = model
    # @param [Project]
    @project = model.project
    @llm = llm
    @redis = RedisFactory.new
  end

  def summarize
    @model.start_tracking(source: 'FindProductsInSummaryService')
    @model.products_status_processing!
    response = nil
    time = measure { response = ask_gpt_to_summarize }
    content = response&.dig('choices', 0, 'message', 'content')
    raise "Output is empty #{response.to_json}" if content.blank?

    success!({ time:, response: }, content)
    @redis.publish(@model.redis_products_name, 'done')
  rescue StandardError => e
    error! e
    raise
  ensure
    @redis.quit
  end

  private

  # @return [Hash]
  def ask_gpt_to_summarize
    llm_model = LLM_MODEL_MAPPING[llm.to_sym]
    raise("Unknown LLM model: #{llm}") if llm_model.nil?

    client = OpenAI::Client.new
    client.chat(parameters: { model: llm_model, messages: [{ role: 'user', content: input }] })
  end

  # @param [Hash] info
  # @param [String] output
  def success!(info, output)
    ProjectArticle.transaction do
      call =
        ProjectLlmCall.save_products_call!(
          @model,
          in_tokens_count: LanguageModelTools.estimate_max_tokens(input),
          out_tokens_count: LanguageModelTools.estimate_max_tokens(output),
          llm:,
          input:,
          output:,
          info:,
        )
      @model.update!(
        info_attributes: {
          products: info,
        },
        related_product_ids: parse_result_get_ids(output),
        products_status: :completed,
        products_llm_call_id: call.id,
      )
    end
  end

  # @return [Array<Integer>]
  def parse_result_get_ids(output)
    result = JSON.parse(output)
    result.filter_map { |p| p['id'] if p['related'] == true }
  rescue JSON::ParserError
    []
  end

  # @param [StandardError] error
  def error!(error)
    info_summary = { error: error.to_s, backtrace: error.backtrace&.grep(%r{/app/})&.join("\n") }
    @model.update!(info_attributes: { products: info_summary }, products_status: :error)
  end

  def input
    return @input if @input
    products_list_str =
      @project
        .products
        .map { |product| "id: #{product.id}, description: #{product.description}" }
        .join("\n")
    @input = format(PREFIX, article: @model.summary_llm_call.output) + products_list_str + POSTFIX
  end

  def measure
    @model.log_info('OpenAI - Begins', type: 'products')
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    time = ending - starting
    @model.log_info('OpenAI - Ends Successfully', type: 'products', time:)
    time
  rescue StandardError => e
    @model.log_info('OpenAI - Ends Unsuccessfully', type: 'products', error: e.to_s)
    raise
  end
end
