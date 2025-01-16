# frozen_string_literal: true
#
# @!attribute project
#  @return [Project]
class ProjectDomainAliasForm
  include ActiveModel::Model

  attr_accessor :project, :url
  validates :url, url: true, length: { maximum: 1000 }

  # @param [Project] project
  # @param [Hash, ActionController::Parameters] params
  def initialize(project, params = {})
    @project = project
    @url = params[:url]
  end

  # def to_key
  #   @project&.id || nil
  # end

  # @return [Boolean]
  def update
    return false if invalid?

    parsed_url = URI.parse(@url)
    project.update(domain_alias: parsed_url.host&.downcase)

    if project.errors.any?
      project.errors.full_messages.each { |msg| errors.add(:base, msg) } and return false
    end

    true
  rescue StandardError => e
    Rails.logger.error e.message
    raise
  end
end
