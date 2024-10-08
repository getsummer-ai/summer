# frozen_string_literal: true

class StatisticService
  # @param [Project] project
  # @param [ProjectPage, ProjectProduct] trackable
  def initialize(project:, trackable:)
    @project = project
    @trackable = trackable
    @time = Time.now.utc
  end

  def view!
    model.increase_views_counter!
  end

  def click!
    # if trackable is a ProjectPage, then we increase clicks counter for it
    # and for the project subscription info
    model.increase_clicks_counter!
    update_subscription_summarize_usage_info if @trackable.is_a?(ProjectPage)
  end

  private

  def model
    @model ||=
      ProjectStatistic.find_or_create_by(
        project: @project,
        trackable: @trackable,
        date: @time.to_date,
        hour: @time.hour,
        date_hour: @time.beginning_of_hour,
      )
  end

  def update_subscription_summarize_usage_info
    # no need to update subscription info if project doesn't have subscription
    # for example, if a project has an enterprise subscription
    return if @project.subscription_id.nil?

    ProjectSubscription.update_counters(@project.subscription_id, summarize_usage: 1)
  end
end
