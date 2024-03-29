# frozen_string_literal: true

class StatisticService

  # @param [Project] project
  # @param [ProjectPage, ProjectService] trackable
  def initialize(project:, trackable:)
    @project = project
    @trackable = trackable
    @time = Time.now.utc
  end

  def view!
    model.increase_views_counter!
  end

  def click!
    model.increase_clicks_counter!
  end

  private

  def model
    @model ||= ProjectStatistic.find_or_create_by(
      project: @project,
      trackable: @trackable,
      date: @time.to_date,
      hour: @time.hour
    )
  end
end
