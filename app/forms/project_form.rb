# frozen_string_literal: true
class ProjectForm
  include ActiveModel::Model

  # serialize :urls, Array

  attr_accessor :urls, :name

  validates :name, presence: true, length: 3..50
  validates :urls, url: { accept_array: true }
  validate :validate_urls, if: -> { errors.empty? }
  validate :validate_first_host, if: -> { errors.empty? }

  MUST_MATCH_ERROR = 'must have the same domain name'

  def validate_urls
    return errors.add(:urls, :invalid) if !urls.is_a?(Array) || urls.empty? || first_host.nil?

    parsed_urls.each do |url|
      errors.add(:urls, MUST_MATCH_ERROR) if first_host != url.host&.downcase
    end
  end

  def validate_first_host
    the_host = first_host.to_s
    host_with_prefix = the_host.start_with?('www.') ? the_host : "www.#{the_host}"
    uniqueness_query =
      @user.projects.available.where(
        domain: [the_host.delete_prefix('www.'), host_with_prefix].uniq,
      )
    return unless uniqueness_query.exists?

    errors.add(:domain, Project::ALREADY_TAKEN_ERROR)
  end

  # @param [User] user
  # @param [Hash, ActionController::Parameters] params
  def initialize(user, params = {})
    @user = user
    @name = params[:name]
    @urls = params[:urls] || ['']
    @project = params[:project]
  end

  def to_key
    @project&.id || nil
  end

  # @return [Project, nil]
  def create
    return nil if invalid?
    model = generate_new_project
    if model.invalid?
      model.errors.full_messages.each { |msg| errors.add(:base, msg) }
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

  def first_host
    @first_host ||= parsed_urls[0].host&.downcase
  end

  # @return [Project]
  def generate_new_project
    model =
      Project.new(
        user_id: @user.id,
        name:,
        protocol: parsed_urls[0].scheme,
        domain: first_host,
        free_clicks_threshold: ENV.fetch('FREE_PLAN_CLICKS_THRESHOLD', 100).to_i,
        default_llm: 'gpt-4o',
        paths: parsed_urls.filter_map(&:path),
      )
    model.start_tracking(source: 'Create Project Form', author: @user)
    model
  end

  # @return [Array<URI::Generic>]
  def parsed_urls
    @parsed_urls ||= @urls.uniq.map { |url| URI.parse(url) }
  end
end
