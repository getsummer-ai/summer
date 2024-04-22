# frozen_string_literal: true
class ProjectDecorator < Draper::Decorator
  delegate_all
  THRESHOLD = ENV.fetch('FREE_PLAN_CLICKS_THRESHOLD').to_i

  def free_plan_left_clicks
    [THRESHOLD - total_clicks, 0].max
  end

  def total_clicks
    @total_clicks ||= total_statistics.total_clicks_count
  end

  def total_views
    @total_views ||= total_statistics.total_views_count
  end

  def total_statistics
    @total_statistics ||= ProjectStatisticsViewModel.new(model, { actions: [:total_action_statistics] })
  end
end
