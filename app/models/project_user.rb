# frozen_string_literal: true
class ProjectUser < ApplicationRecord
  include Trackable
  include PassiveColumns

  enum :role, { owner: 'owner', admin: 'admin', viewer: 'viewer' }, validate: true

  # one owner is only possible per project
  validates :role, uniqueness: { scope: :project_id, conditions: -> { where(role: :owner) } }

  belongs_to :user, optional: true
  belongs_to :project
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
