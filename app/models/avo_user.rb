# frozen_string_literal: true

class AvoUser < User
  self.table_name = 'users'
  has_many :all_events, class_name: 'AvoEvent', as: :author, dependent: :restrict_with_exception
  has_many :projects, class_name: 'AvoProject', foreign_key: 'user_id', dependent: :restrict_with_exception
  belongs_to :default_project, class_name: 'AvoProject', optional: true

  before_destroy :stop_destroy


  def self.ransackable_attributes(auth_object = nil)
    %w[id email name]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[all_events default_project events projects]
  end


  def stop_destroy
    errors.add(:base, :undestroyable)
    throw :abort
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  avatar_url             :text
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  is_admin               :boolean          default(FALSE), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locale                 :enum             default("en"), not null
#  locked_at              :datetime
#  name                   :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  default_project_id     :bigint
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_default_project_id    (default_project_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (default_project_id => projects.id) ON DELETE => nullify ON UPDATE => cascade
#
