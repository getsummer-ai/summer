# frozen_string_literal: true

class AvoEvent < Event
  has_many :all_events, class_name: 'AvoEvent', foreign_key: 'project_id'
  belongs_to :project, class_name: 'AvoProject'

  before_destroy :stop_destroy

  def stop_destroy
    errors.add(:base, :undestroyable)
    throw :abort
  end
end
