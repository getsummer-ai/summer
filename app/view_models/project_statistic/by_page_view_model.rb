# frozen_string_literal: true

class ProjectStatistic
  class ByPageViewModel
    attr_reader :month

    # @param [Project] project
    # @param [Date] month
    def initialize(project, month = nil)
      # @type [Project]
      @project = project
      # @type [Date]
      @month = month&.beginning_of_month || Time.zone.today.beginning_of_month
    end

    # @return [Integer]
    def total_pages_count = total_pages_statistics.value

    # @return [Integer]
    def current_month_new_pages_count
      total_pages_count - (previous_month_total_pages_statistics.value || 0)
    end

    # @return [Integer]
    def total_views_count = total_action_statistics.value.dig(0, 0) || 0

    # @return [Integer]
    def total_clicks_count = total_action_statistics.value.dig(0, 1) || 0

    # @return [Integer]
    def current_month_new_views_count = current_month_action_statistics.value.dig(0, 0) || 0

    # @return [Integer]
    def current_month_new_clicks_count = current_month_action_statistics.value.dig(0, 1) || 0

    def views_clicks_by_days_for_chart
      group_column = "DATE_TRUNC('day', \"project_statistics\".\"date_hour\")::date"

      result =
        @project
          .statistics
          .by_pages
          .where(date_hour: @month.to_time.utc.all_month)
          .group(group_column)
          .order(Arel.sql("#{group_column} asc"))
          .pluck(Arel.sql("SUM(views)::int, SUM(clicks)::int, #{group_column}"))
          .to_a

      empty_series = @month.all_month.to_a.index_with { 0.5 }

      {
        shown:
          result
            .to_h { |views, _, date| [date, views.zero? ? 0.5 : views] }
            .reverse_merge(empty_series),
        clicked:
          result
            .to_h { |_, clicks, date| [date, clicks.zero? ? 0.5 : clicks] }
            .reverse_merge(empty_series),
      }
    end

    def statistic_months
      return @statistic_months if defined?(@statistic_months)
      res = @project.statistics_by_month.by_pages.distinct.order(month: :desc).pluck(:month)
      @statistic_months = res.empty? ? [@month] : res
    end

    def preload_view_totals = total_pages_statistics
    def preload_previous_month_view_totals = previous_month_total_pages_statistics
    def preload_click_totals = total_action_statistics
    def preload_current_month_click_totals = current_month_action_statistics

    private

    def start_preload_queries
      PRELOAD_QUERIES_SCHEMA.each do |preload, queries|
        next unless @preloads.include?(preload)

        queries = @preloads[preload] if @preloads.is_a?(Hash)
        queries.each { |query| send(query) }
      end
    end

    # @return [ActiveRecord::Promise]
    def total_pages_statistics
      @total_pages_statistics ||=
        @project
          .statistics_by_month
          .by_pages
          .where('month <= :month', month:)
          .distinct
          .async_count(:trackable_id)
    end

    # @return [ActiveRecord::Promise]
    def previous_month_total_pages_statistics
      @previous_month_total_pages_statistics ||=
        @project
          .statistics_by_month
          .by_pages
          .where('month < :month', month:)
          .distinct
          .async_count(:trackable_id)
    end

    # @return [ActiveRecord::Promise]
    def total_action_statistics
      @total_action_statistics ||=
        @project
          .statistics_by_month
          .by_pages
          .where('month <= :month', month:)
          .group(:project_id)
          .async_pluck(Arel.sql('SUM(views)::BIGINT, SUM(clicks)::BIGINT'))
    end

    # @return [ActiveRecord::Promise]
    def current_month_action_statistics
      @current_month_action_statistics ||=
        @project
          .statistics_by_month
          .by_pages
          .where(month:)
          .group(:project_id)
          .async_pluck(Arel.sql('SUM(views)::BIGINT, SUM(clicks)::BIGINT'))
    end
  end
end
