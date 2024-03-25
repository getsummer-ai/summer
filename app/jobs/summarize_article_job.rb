# frozen_string_literal: true
class SummarizeArticleJob < ApplicationJob
  queue_as :default
  # retry_on StandardError, attempts: 2

  def self.perform(*args)
    new.perform(*args)
  end

  # @param [Integer] id
  def perform(id)
    model = ProjectArticle.includes(:project).find(id)
    project = model.project
    model_wrapper = SummarizeArticleService.new(
      model:,
      llm: project.default_llm,
      guidelines: project.guidelines
    )
    model_wrapper.summarize
  end
end
