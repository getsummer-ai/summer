# frozen_string_literal: true
#
# @!attribute project
#  @return [Project]
# @!attribute url
# @return [String]
class ProjectDomainAliasForm
  include ActiveModel::Model

  attr_accessor :project, :url
  validates :url, url: true, length: { maximum: 1000 }
  validate :host_not_blank, if: -> { url.present? && errors.empty? }

  # @param [Project] project
  # @param [Hash, ActionController::Parameters] params
  def initialize(project, params = {})
    @project = project
    @url = "#{@project.protocol}://#{@project.domain_alias}"
    @url = params[:url] if params.present?
  end

  def host_not_blank
    return if URI.parse(url).host.present?
    errors.add(:url, :blank)
  rescue URI::InvalidURIError
    errors.add(:url, :invalid)
  end

  def domain_alias_set_previously?
    project.domain_alias.present? && errors.empty?
  end

  # @return [Boolean]
  def update
    return false if invalid?

    parsed_url = URI.parse(url)
    project.update(domain_alias: parsed_url.host&.downcase)

    if project.errors.any?
      project.errors[:domain_alias].each { |msg| errors.add(:url, msg) } and return false
    end

    true
  rescue StandardError => e
    Rails.logger.error e.message
    raise
  end
end
