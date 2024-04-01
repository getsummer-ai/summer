# frozen_string_literal: true

class ProjectUserEmail < ApplicationRecord

  belongs_to :project
  belongs_to :project_page

  validates :encrypted_page_id, :email, presence: true

  validates :encrypted_page_id, uniqueness: true, if: -> { errors.empty? }
  validates :email, format: { with: Devise.email_regexp }, if: -> { errors.empty? }
  validates :email, uniqueness: { scope: [:project_id] }, if: -> { errors.empty? }

  normalizes :email, with: -> (email) { email.downcase.strip }

  def to_param
    encrypted_id
  end

  def encrypted_id
    return nil if id.nil?
    @encrypted_id ||= BasicEncrypting.encode(id)
  end
end

# == Schema Information
#
# Table name: project_user_emails
#
#  id                :bigint           not null, primary key
#  email             :string           not null
#  uuid              :uuid             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  encrypted_page_id :string           not null
#  project_id        :bigint           not null
#  project_page_id   :bigint           not null
#
# Indexes
#
#  index_project_user_emails_on_encrypted_page_id     (encrypted_page_id) UNIQUE
#  index_project_user_emails_on_project_id_and_email  (project_id,email) UNIQUE
#  index_project_user_emails_on_uuid                  (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (project_page_id => project_pages.id) ON DELETE => cascade ON UPDATE => cascade
#
