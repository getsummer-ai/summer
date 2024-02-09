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

  # @param [Integer] id
  def perform(id)
    # @type [ProjectArticle]
    model = ProjectArticle.includes(:project).find(id)
    model.status_processing!
    begin
      response = nil
      time = measure_time { response = ask_gpt_to_summarize(PREFIX + model.article) }
      model.update!(
        service_info: { time:, response: },
        summary: response&.dig('choices', 0, 'message', 'content'),
        status: :summarized,
        llm: model.llm.presence || model.project.default_llm,
        summarized_at: Time.zone.now.utc,
      )
    rescue StandardError => e
      model.update!(service_info: { error: e.to_s }, status: :error)
      raise
    end
  end

  protected

  def measure_time
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    ending - starting
  end

  # @param [String] message
  def ask_gpt_to_summarize(message)
    client = OpenAI::Client.new
    client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: message }],
      },
    )
  end
end
