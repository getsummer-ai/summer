# frozen_string_literal: true
class ProjectPathForm
  include ActiveModel::Model

  attr_accessor :path, :value

  validates :value, presence: true
  validates :value, url: true
  validate :check_domain_correctness

  validates :path, presence: true, allow_blank: true, on: [:update, :destroy]
  validate :check_path_existence, on: [:update, :destroy]

  def check_domain_correctness
    return if parsed_value&.host == @project.domain
    errors.add(:value, :invalid)
  end

  def check_path_existence
    return if @project_path.persisted?
    errors.add(:path, :invalid)
  end

  # @param [Project::ProjectPath] project_path
  # @param [String, nil] value
  def initialize(project_path, value: nil)
    # @type [Project::ProjectPath]
    @project_path = project_path
    # @type [Project]
    @project = project_path.project
    @path = project_path.path
    @value = value
    return if @path.nil?

    @value = @value.nil? ? project_path.url : @value
  end

  def create
    return nil if invalid?

    @project.track!(source: 'Add Project Path', author: @project.user) do
      @project.paths << parsed_value&.path
      @project.save
    end

    return true if @project.errors.empty?

    pass_project_errors_to_model
    nil
  end

  def update
    return nil if invalid?(:update)

    @project.track!(source: 'Update Project Path', author: @project.user) do
      @project.paths[@project.paths.find_index(path)] = parsed_value&.path
      @project.save
    end

    return true if @project.errors.empty?

    pass_project_errors_to_model
    nil
  end

  def destroy
    return nil if invalid?(:destroy)

    @project.track!(source: 'Delete Path', author: current_user) do
      @project.paths.delete_at(@project.paths.find_index(@project_path))
      @project.save
    end

    return true if @project.errors.empty?

    pass_project_errors_to_model
    nil
  end

  def pass_project_errors_to_model
    @project.errors.full_messages.each { |msg| errors.add(:base, msg) }
  end

  def parsed_value
    return nil if value.nil?
    @parsed_value ||= URI.parse(value)
  end

  def to_param
    @project_path.id
  end
end
