# frozen_string_literal: true
class ProjectUserForm
  include ActiveModel::Model

  attr_accessor :email, :role, :project_user

  validates :role, presence: true
  validates :email, presence: true, format: { with: Devise.email_regexp }, if: -> { errors.empty? }

  delegate :id, :to_param, :persisted?, :new_record?, to: :project_user

  # @param [ProjectUser] project_user
  def initialize(project_user, attributes = {})
    # @type [ProjectUser]
    @project_user = project_user
    # @type [Project]
    @project = project_user.project
    @email = attributes[:email].presence || project_user.user&.email || project_user.invited_email_address
    @role = attributes[:role] || project_user.role
  end

  def save
    return false if invalid?

    @project_user.role = role
    @project_user.invited_email_address = email.strip.downcase
    if @project_user.new_record? || @project_user.invited_email_address_changed?
      @project_user.user = User.find_by(email: email)
    end

    return true if @project_user.save

    @project_user.errors.full_messages.each { |msg| errors.add(:base, msg) }
    false
  end
end
