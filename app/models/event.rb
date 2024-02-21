# frozen_string_literal: true
#
# Store models changes information.
#
class Event < ApplicationRecord
  # belongs_to :project
  belongs_to :trackable, polymorphic: true
  belongs_to :author, polymorphic: true, optional: true
  belongs_to :project

  store :details, accessors: %i[changes snapshot info], coder: JsonbSerializer

  # serialize :details, JsonbSerializer

  scope :logs, -> { where(category: 'log') }

  after_initialize do
    self.category ||= 'log'
    self.changes ||= {}
  end

  before_create :set_project_id

  ### Predicates
  def log?
    self.category == 'log'
  end

  def set_project_id
    self.project_id ||= trackable.try(:project_id)
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
