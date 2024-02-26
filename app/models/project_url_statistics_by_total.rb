# frozen_string_literal: true

class ProjectUrlStatisticsByTotal < ApplicationRecord
  self.primary_key = :project_url_id
  belongs_to :project_url

  def readonly?
    true
  end
end

# == Schema Information
#
# Table name: project_url_statistics_by_totals
#
#  clicks         :bigint
#  views          :bigint
#  project_url_id :bigint           primary key
#
