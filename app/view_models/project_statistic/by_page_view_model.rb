# frozen_string_literal: true

class ProjectStatistic
  class ByPageViewModel
    attr_reader :month

    # @param [Project] project
    # @param [Date] month
    # @param [Integer] page_id
    def initialize(project, month, page_id: nil)
      # @type [Project]
      @project = project
      # @type [Date]
      @month = month.beginning_of_month
      # @type [Integer]
      @page_id = page_id
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
      query = @project
        .statistics
        .by_pages
        .where(date_hour: @month.to_time.utc.all_month)
        .group(group_column)
        .order(Arel.sql("#{group_column} asc"))

      query = query.where(trackable_id: @page_id) if @page_id.present?
      result = query.pluck(Arel.sql("SUM(views)::int, SUM(clicks)::int, #{group_column}")).to_a

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

    def preload_page_totals = (total_pages_statistics and self)

    def preload_previous_month_page_totals = (previous_month_total_pages_statistics and self)

    def preload_view_click_totals = (total_action_statistics and self)

    def preload_current_month_view_click_totals = (current_month_action_statistics and self)

    private

    # @return [ActiveRecord::Promise]
    def total_pages_statistics
      @total_pages_statistics ||=
        @project
          .statistics_by_month
          .by_pages
          .for_id_if_exists(@page_id)
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
          .for_id_if_exists(@page_id)
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
          .for_id_if_exists(@page_id)
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
          .for_id_if_exists(@page_id)
          .where(month:)
          .group(:project_id)
          .async_pluck(Arel.sql('SUM(views)::BIGINT, SUM(clicks)::BIGINT'))
    end
  end
end
