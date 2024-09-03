# frozen_string_literal: true
class ProjectDecorator < Draper::Decorator
  delegate_all

  def plan_left_clicks
    return free_plan_left_clicks if model.free_plan?
    return light_plan_left_clicks if model.light_plan?
    return pro_plan_left_clicks if model.pro_plan?
    return Float::INFINITY if model.enterprise_plan?
    0
  end

  def subscription_expiration_time
    Time.at(model.stripe.subscription.cancel_at).utc if model.stripe.subscription.cancel_at.present?
  end

  def free_plan_left_clicks
    [project.free_clicks_threshold - total_clicks_count, 0].max
  end

  def light_plan_left_clicks
    [Project::LIGHT_PLAN_THRESHOLD - current_month_new_clicks_count, 0].max
  end

  def pro_plan_left_clicks
    [Project::PRO_PLAN_THRESHOLD - current_month_new_clicks_count, 0].max
  end

  delegate :total_product_views, to: :total_statistics
  delegate :current_month_new_clicks_count, to: :total_statistics
  delegate :total_clicks_count, to: :total_statistics
  delegate :total_views_count, to: :total_statistics

  def total_statistics
    @total_statistics ||= ProjectStatisticsViewModel.new(model)
  end
end
