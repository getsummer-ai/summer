# frozen_string_literal: true
#
# @!attribute project
#  @return [Project]
# @!attribute url
# @return [String]
class ProjectDomainAliasForm
  include ActiveModel::Model

  attr_accessor :project, :url, :user
  validates :url, url: true, length: { maximum: 1000 }

  with_options if: -> { url.present? } do
    validate :host_not_blank, if: -> { errors.empty? }
    validate :domain_and_alias_are_different, if: -> { errors.empty? }
    validate :validate_alias_uniqueness, if: -> { errors.empty? }
  end

  # @param [Project] project
  # @param [User] user
  # @param [Hash, ActionController::Parameters] params
  def initialize(project, user, params = {})
    @project = project
    @user = user
    @url = "#{@project.protocol}://#{@project.domain_alias}"
    @url = params[:url] if params.present?
  end

  def domain_alias_set_previously?
    project.domain_alias.present? && errors.empty?
  end

  # @return [Boolean]
  def update
    return false if invalid?

    project.update(domain_alias: parsed_host_from_url&.downcase)

    if project.errors.any?
      project.errors[:domain_alias].each { |msg| errors.add(:url, msg) } and return false
    end

    true
  rescue StandardError => e
    Rails.logger.error e.message
    raise
  end

  private

    # @return [String, nil]
    def parsed_host_from_url
      @parsed_host_from_url ||= URI.parse(url).host
    end


    def host_not_blank
      return if parsed_host_from_url.present?
      errors.add(:url, :blank)
    rescue URI::InvalidURIError
      errors.add(:url, :invalid)
    end

    def domain_and_alias_are_different
      return if project.domain != parsed_host_from_url&.downcase
      errors.add(:base, :same_as_domain_name, domain: project.domain)
    end

    def validate_alias_uniqueness
      domain_alias = parsed_host_from_url&.downcase
      existing_project = @user.projects.available.where(domain_alias:).where.not(id: project.id).take
      return if existing_project.blank?
      
      errors.add(
        :base, :domain_alias_is_already_taken, domain_alias: domain_alias, project_name: existing_project.name
      )
    end
end
