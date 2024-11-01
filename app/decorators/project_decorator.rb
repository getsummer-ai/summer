# frozen_string_literal: true
class ProjectDecorator < Draper::Decorator
  delegate_all

  def plan_left_clicks
    return Float::INFINITY if model.subscription_id.nil?
    subscription = model.subscription
    [subscription.summarize_limit - subscription.summarize_usage, 0].max
  end

  delegate :total_product_views, to: :total_statistics
  delegate :current_month_new_clicks_count, to: :total_statistics
  delegate :total_clicks_count, to: :total_statistics
  delegate :total_views_count, to: :total_statistics

  def total_statistics
    @total_statistics ||= ProjectStatistic::TotalsViewModel.new(model)
  end
end
