# frozen_string_literal: true
class FindProductsInSummaryJob < ApplicationJob
  queue_as :default
  # retry_on StandardError, attempts: 2

  def self.perform(*args)
    new.perform(*args)
  end

  # @param [Integer] id
  def perform(id)
    # @type [ProjectArticle]
    model = ProjectArticle.includes(:project).find(id)
    model_wrapper = FindProductsInSummaryService.new(model:, llm: model.project.default_llm)
    model_wrapper.summarize
  end
end
