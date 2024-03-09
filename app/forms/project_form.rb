# frozen_string_literal: true
class ProjectForm
  include ActiveModel::Model

  attr_accessor :urls, :name

  validates :name, presence: true, length: 3..50
  validates :urls, url: { accept_array: true }
  validate :validate_urls

  def validate_urls
    errors.add(:urls, :invalid) unless urls.is_a?(Array)

    host = URI.parse(@urls.first).host&.downcase
    urls.each { |url| errors.add(:urls, :invalid) if host != URI.parse(url).host&.downcase }
  end

  # @param [User] user
  # @param [Hash, ActionController::Parameters] params
  def initialize(user, params = {})
    @user = user
    @name = params[:name]
    @urls = params[:urls]
    @project = params[:project]
  end

  def self.from_project(project)
    urls = project.paths_array.map { |path| "#{project.protocol}://#{project.domain}#{path}" }
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
      model.errors.each { |k, v| errors.add(k, v) } and return
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
    model = Project.new(user_id: @user.id, protocol:, domain:, paths_array: parsed_urls.map(&:path))
    model.start_tracking(source: 'Create Project Form', author: @user)
    model
  end

  # @return [Array<URI::HTTP>]
  def parsed_urls
    @parsed_urls ||= @urls.map { |url| URI.parse(url) }
  end

  # @return [String]
  def protocol
    parsed_urls[0].split('://').first
  end

  # @return [String]
  def domain
    parsed_urls[0].split('://').last.split('/').first
  end
end
