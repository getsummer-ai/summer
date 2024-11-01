# frozen_string_literal: true
#
# This job is responsible for refreshing the project_statistics_by_month materialized view
class RefreshProjectStatisticsByMonthJob < ApplicationJob
  queue_as :default

  def self.perform(*args)
    new.perform(*args)
  end

  def perform(*)
    ProjectStatisticsByMonth.refresh
  end
end
