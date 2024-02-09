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
