# frozen_string_literal: true

class ProjectStatisticsByMonth < ApplicationRecord
  self.primary_key = [:trackable_type, :trackable_id]
  belongs_to :project
  belongs_to :trackable, polymorphic: true

  scope :by_pages, -> { where(trackable_type: ProjectPage.to_s) }
  scope :by_products, -> { where(trackable_type: ProjectProduct.to_s) }

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: false)
  end
end

# == Schema Information
#
# Table name: project_statistics_by_months
#
#  clicks         :bigint
#  month          :date
#  trackable_type :string           primary key
#  views          :bigint
#  project_id     :bigint
#  trackable_id   :bigint           primary key
#
# Indexes
#
#  idx_on_project_id_trackable_type_trackable_id_month_87660b5378  (project_id,trackable_type,trackable_id,month)
#  idx_on_trackable_type_trackable_id_month_ac97d1a671             (trackable_type,trackable_id,month) UNIQUE
#
