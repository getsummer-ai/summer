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
      llm: llm_for(project),
      guidelines: project.guidelines
    )
    model_wrapper.summarize
  end

  protected

  # @param [Project] project
  def llm_for(project)
    res = Project.default_llms[project.default_llm]
    res = Project.default_llms[:gpt_4o_mini] if Rails.env.development?
    res.to_s
  end
end
