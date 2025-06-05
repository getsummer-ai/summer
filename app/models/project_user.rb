# frozen_string_literal: true
class ProjectUser < ApplicationRecord
  include Trackable
  include EncryptedKey
  include PassiveColumns

  enum :role, { owner: 'owner', admin: 'admin', viewer: 'viewer' }, validate: true

  # one owner is only possible per project
  validates :role,
            uniqueness: {
              scope: :project_id,
              conditions: -> { where(role: :owner) }
            }, if: -> { role == 'owner' }

  validates :invited_email_address, uniqueness: { scope: [:project_id] }, if: -> { errors.empty? }

  belongs_to :user, optional: true
  belongs_to :project

  scope :admins_and_viewers, -> { where(role: [:admin, :viewer]) }

  after_destroy :remove_default_project_selection_for_user, if: -> { user_id.present? }

  def email
    invited_email_address.presence || user&.email
  end

  def send_invitation
    return if invited_email_address.blank? || user_id.present?

    ProjectMailer.added_user_invitation_email(id).deliver_now
    update_attribute! :invitation_sent_at, Time.now.utc
  end

  private

  def remove_default_project_selection_for_user
    return if user.nil? || user.default_project_id != project_id

    user.update(default_project_id: nil)
  end
end

# == Schema Information
#
# Table name: project_users
#
#  id                    :bigint           not null, primary key
#  invitation_sent_at    :datetime
#  invited_email_address :string
#  role                  :enum             default("admin"), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  project_id            :bigint           not null
#  user_id               :bigint
#
# Indexes
#
#  index_project_users_on_project_id              (project_id)
#  index_project_users_on_user_id                 (user_id)
#  index_project_users_on_user_id_and_project_id  (user_id,project_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
#
