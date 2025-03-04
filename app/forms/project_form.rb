# frozen_string_literal: true
class ProjectForm
  include ActiveModel::Model

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
    create_form = Project::CreateNewService.new(
      @user,
      name:,
      protocol: parsed_urls[0].scheme,
      domain: first_host,
      paths: parsed_urls.filter_map(&:path),
    )
    model = create_form.create(log_source: 'Create Project Form')
    if model.invalid?
      model.errors.full_messages.each { |msg| errors.add(:base, msg) } and return nil
    end
    model
  rescue StandardError => e
    Rails.logger.error e.message
    raise
  end

  private

  def first_host
    @first_host ||= parsed_urls[0].host&.downcase
  end

  # @return [Array<URI::Generic>]
  def parsed_urls
    @parsed_urls ||= @urls.uniq.map { |url| URI.parse(url) }
  end
end
