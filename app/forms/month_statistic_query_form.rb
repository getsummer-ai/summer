# frozen_string_literal: true
class MonthStatisticQueryForm
  include ActiveModel::Model

  attr_accessor :month
  validates :month, presence: true
  validate :check_date

  GROUP_COLUMN = "DATE_TRUNC('day', \"project_statistics\".\"date_hour\")::date"

  def check_date
    Date.strptime(month, '%Y-%m-%d')
  rescue ArgumentError
    errors.add(:base, 'Invalid date')
  end

  # @param [Project] current_project
  # @param [Hash, ActionController::Parameters] params
  def initialize(current_project, params)
    @current_project = current_project
    @month =
      params[:month] || statistic_basic_query.maximum(:date_hour).to_date.beginning_of_month.to_s
  end

  def result_for_chart
    return [] if invalid?

    result = calculate_for_timeframe(month_as_date).to_a
    empty_series = month_as_date.all_month.to_a.index_with { 0 }

    [
      {
        name: 'Button shown',
        data: result.to_h { |views, _clicks, date| [date, views] }.reverse_merge(empty_series),
      },
      {
        name: 'Button clicked',
        data: result.to_h { |_views, clicks, date| [date, clicks] }.reverse_merge(empty_series),
      },
    ]
  end

  def statistic_months
    return @statistic_months if defined?(@statistic_months)

    col = "DATE_TRUNC('month', \"project_statistics\".\"date_hour\")::date"
    @statistic_months =
      statistic_basic_query.distinct.order(Arel.sql("#{col} asc")).pluck(Arel.sql(col))
  end

  private

  def calculate_for_timeframe(date)
    statistic_basic_query
      .where(date_hour: date.all_month)
      .group(GROUP_COLUMN)
      .order(Arel.sql("#{GROUP_COLUMN} asc"))
      .pluck(Arel.sql("SUM(views)::int, SUM(clicks)::int, #{GROUP_COLUMN}"))
  end

  def statistic_basic_query
    @current_project.statistics.where(trackable_type: 'ProjectPage')
  end

  def month_as_date
    @month_as_date ||= Date.strptime(month, '%Y-%m-%d')
  end
end
