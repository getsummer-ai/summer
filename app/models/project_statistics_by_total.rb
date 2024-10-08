# frozen_string_literal: true

class ProjectStatisticsByTotal < ApplicationRecord
  self.primary_key = [:trackable_type, :trackable_id]
  belongs_to :project
  belongs_to :trackable, polymorphic: true

  def readonly?
    true
  end
end

# == Schema Information
#
# Table name: project_statistics_by_totals
#
#  clicks         :bigint
#  trackable_type :string           primary key
#  views          :bigint
#  project_id     :bigint
#  trackable_id   :bigint           primary key
#
