# frozen_string_literal: true
class ProjectDecorator < Draper::Decorator
  delegate_all

  def plan_left_clicks
    return free_plan_left_clicks if model.free_plan?
    return light_plan_left_clicks if model.light_plan?
    return pro_plan_left_clicks if model.pro_plan?
    0
  end

  def free_plan_left_clicks
    [Project::FREE_PLAN_THRESHOLD - total_clicks, 0].max
  end

  def light_plan_left_clicks
    [Project::LIGHT_PLAN_THRESHOLD - current_month_clicks, 0].max
  end

  def pro_plan_left_clicks
    [Project::PRO_PLAN_THRESHOLD - current_month_clicks, 0].max
  end

  def current_month_clicks
    @current_month_clicks ||= total_statistics.current_month_new_clicks_count
  end

  def total_clicks
    @total_clicks ||= total_statistics.total_clicks_count
  end

  def total_views
    @total_views ||= total_statistics.total_views_count
  end

  def total_statistics
    @total_statistics ||= ProjectStatisticsViewModel.new(model)
  end
end
