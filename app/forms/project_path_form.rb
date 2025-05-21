# frozen_string_literal: true
class ProjectPathForm
  include ActiveModel::Model

  attr_accessor :path, :project_path, :value

  validates :value, presence: true
  validates :value, url: true, if: -> { errors.empty? }
  validate :check_domain_correctness, if: -> { errors.empty? }
  validate :check_path_uniqueness, if: -> { errors.empty? }
  validate :check_paths_max_count, on: %i[create], if: -> { errors.empty? }

  validates :path, presence: true, allow_blank: true, on: %i[update destroy]
  validate :check_path_existence, on: %i[update destroy]
  validate :check_if_path_is_last, on: %i[destroy], if: -> { errors.empty? }

  def check_domain_correctness
    return if parsed_value&.host == @project.domain
    errors.add(:base, "The URL must belong to #{@project.domain}")
  end

  def check_path_uniqueness
    return if not_changed?
    return unless @project.paths.include?(parsed_value&.path)
    errors.add(:base, 'URL already exists')
  end

  def check_if_path_is_last
    return if @project.paths.count > 1
    errors.add(:base, 'You cannot delete the last URL')
  end

  def check_paths_max_count
    return if @project.paths.count < 5
    errors.add(:base, 'Max URL amount is 5')
  end

  def check_path_existence
    return if @project_path.persisted?
    errors.add(:path, :invalid)
  end

  # @param [Project::ProjectPath] project_path
  # @param [String, nil] value
  # @param [User, nil] user
  def initialize(project_path, value: nil, user: nil)
    # @type [Project::ProjectPath]
    @project_path = project_path
    # @type [Project]
    @project = project_path.project
    @path = project_path.path
    @user = user
    @value = value
    return if @path.nil?

    @value = @value.nil? ? project_path.url : @value
  end

  def create
    return nil if invalid?(:create)

    @project.track!(source: 'Add Project Path', author: @user) do
      @project.paths << parsed_value&.path
      @project.save
    end

    return true if @project.errors.empty?

    pass_project_errors_to_model
    nil
  end

  # @return [Project::ProjectPath, nil]
  def update
    return nil if invalid?(:update)

    @project.track!(source: 'Update Project Path', author: @user) do
      @project.paths[@project.paths.find_index(path)] = parsed_value&.path
      @project.save
    end

    if @project.errors.empty?
      return Project::ProjectPath.new(@project, parsed_value&.path)
    end

    pass_project_errors_to_model
    nil
  end

  def destroy
    return nil if invalid?(:destroy)

    @project.track!(source: 'Delete Path', author: @user) do
      @project.paths.delete_at(@project.paths.find_index(@path))
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

  def not_changed?
    parsed_value&.path == @project_path.path
  end

  def to_param
    @project_path.id
  end

  def persisted?
    !@project_path.path.nil?
  end

  def to_key
    return nil if @path.nil?
    [@project_path.id]
  end
end
