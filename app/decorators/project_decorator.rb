# frozen_string_literal: true
class ProjectDecorator < Draper::Decorator
  delegate_all
  THRESHOLD = ENV.fetch('FREE_PLAN_CLICKS_THRESHOLD').to_i

  def free_plan_left_clicks
    [THRESHOLD - total_clicks, 0].max
  end

  def total_clicks
    @total_clicks ||= begin
      statistic = ProjectStatisticsViewModel.new(model, { actions: [:total_action_statistics] })
      statistic.total_clicks_count
    end
  end
end
