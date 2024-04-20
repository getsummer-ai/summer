# frozen_string_literal: true
class ProjectDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def free_plan_left_clicks
    [500 - total_clicks, 0].max
  end

  def total_clicks
    @total_clicks ||= begin
      statistic = ProjectStatisticsViewModel.new(model, { actions: [:total_action_statistics] })
      statistic.total_clicks_count
    end
  end
end
