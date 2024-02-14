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

# == Schema Information
#
# Table name: events
#
#  id             :bigint           not null, primary key
#  author_type    :string
#  category       :string           not null
#  details        :jsonb            not null
#  source         :string
#  subcategory    :string           not null
#  trackable_type :string
#  created_at     :datetime         not null
#  author_id      :bigint
#  project_id     :bigint
#  trackable_id   :bigint
#
# Indexes
#
#  index_events_on_author                 (author_type,author_id)
#  index_events_on_created_at             (created_at)
#  index_events_on_project_id_and_source  (project_id,source)
#  index_events_on_source                 (source)
#  index_events_on_trackable              (trackable_type,trackable_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade ON UPDATE => cascade
#
