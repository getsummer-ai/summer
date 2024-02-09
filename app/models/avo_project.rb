# frozen_string_literal: true

class AvoProject < Project
  has_many :all_events, class_name: 'AvoEvent', foreign_key: 'project_id'
  belongs_to :user, class_name: 'AvoUser'

  before_destroy :stop_destroy

  def to_param
    id
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[domain id name]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[all_events events project_article_statistics project_articles project_urls user]
  end


  def stop_destroy
    errors.add(:base, :undestroyable)
    throw :abort
  end
end
