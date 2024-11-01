# frozen_string_literal: true

class ProjectStatistic < ApplicationRecord
  belongs_to :project
  belongs_to :trackable, polymorphic: true

  scope :by_pages, -> { where(trackable_type: ProjectPage.to_s) }
  scope :by_products, -> { where(trackable_type: ProjectProduct.to_s) }
  scope :current_month, -> { where(date: Time.now.utc.all_month) }

  # scope :for_month, ->(month) { where(month: month.to_s) }
  # scope :up_to_month, ->(month) { where('date_hour <= :month', month: month.to_s) }

  def increase_views_counter!
    self.class.update_counters(id, views: 1)
  end

  def increase_clicks_counter!
    self.class.update_counters(id, clicks: 1)
  end
end

# == Schema Information
#
# Table name: project_statistics
#
#  id             :bigint           not null, primary key
#  clicks         :bigint           default(0), not null
#  date           :date             not null
#  date_hour      :datetime         not null
#  hour           :integer          not null
#  trackable_type :string
#  views          :bigint           default(0), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  project_id     :bigint           not null
#  trackable_id   :bigint
#
# Indexes
#
#  idx_on_project_id_trackable_type_trackable_id_date__92da09a367  (project_id,trackable_type,trackable_id,date,hour) UNIQUE
#  idx_on_project_id_trackable_type_trackable_id_date__9b38d2b2a3  (project_id,trackable_type,trackable_id,date_hour) UNIQUE
#  index_project_statistics_on_project_id                          (project_id)
#  index_project_statistics_on_project_id_and_date                 (project_id,date)
#  index_project_statistics_on_project_id_and_date_hour            (project_id,date_hour)
#  index_project_statistics_on_trackable                           (trackable_type,trackable_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON UPDATE => cascade
#
