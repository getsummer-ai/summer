# frozen_string_literal: true
class ProjectForm
  include ActiveModel::Model

  # serialize :urls, Array

  attr_accessor :urls, :name

  validates :name, presence: true, length: 3..50
  validates :urls, url: { accept_array: true }
  validate :validate_urls

  def validate_urls
    return errors.add(:urls, :invalid) unless urls.is_a?(Array)

    host = parsed_urls[0].host&.downcase
    errors.add(:urls, :invalid) if host.nil?
    parsed_urls.each { |url| errors.add(:urls, :invalid) if host != url.host&.downcase }
  end

  # @param [User] user
  # @param [Hash, ActionController::Parameters] params
  def initialize(user, params = {})
    @user = user
    @name = params[:name]
    @urls = params[:urls] || ['']
    @project = params[:project]
  end

  def self.from_project(project)
    urls = project.paths.map { |path| "#{project.protocol}://#{project.domain}#{path}" }
    new(project.user_id, name: project.name, urls:)
  end

  def to_key
    @project&.id || nil
  end

  # @return [Project, nil]
  def create
    return nil if invalid?
    model = generate_new_project
    if model.invalid?
      model.errors.full_messages.each{ |msg| errors.add(:base, msg) }
      return nil
    end

    res = model.save(validate: false)
    return nil unless res
    model
  rescue StandardError => e
    Rails.logger.error e.message
    raise
  end

  private

  # @return [Project]
  def generate_new_project
    model = Project.new(
      user_id: @user.id,
      name:,
      protocol:,
      domain:,
      paths: parsed_urls.map(&:path).compact_blank
    )
    model.start_tracking(source: 'Create Project Form', author: @user)
    model
  end

  # @return [Array<URI::Generic>]
  def parsed_urls
    @parsed_urls ||= @urls.map { |url| URI.parse(url) }
  end

  # @return [String, nil]
  def protocol
    parsed_urls[0].scheme
  end

  # @return [String, nil]
  def domain
    parsed_urls[0].host
  end
end
