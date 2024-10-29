# frozen_string_literal: true

class ProjectStatistic
  class TotalsViewModel
    PRELOAD_QUERIES_SCHEMA = {
      pages: %i[preload_view_totals preload_previous_month_view_totals],
      actions: %i[preload_click_totals preload_current_month_click_totals],
    }.freeze

    attr_reader :month

    delegate :total_product_views, to: :product_statistics

    delegate :preload_view_totals,
             :preload_click_totals,
             :preload_current_month_click_totals,
             :preload_previous_month_view_totals,
             to: :page_statistics

    delegate :total_pages_count,
             :total_views_count,
             :total_clicks_count,
             :current_month_new_pages_count,
             :current_month_new_views_count,
             :current_month_new_clicks_count,
             :views_clicks_by_days_for_chart,
             :statistic_months,
             to: :page_statistics

    # @param [Project] project
    # @param [Date] month
    # @param [Array<Symbol>, Hash] preloads
    def initialize(project, month = nil, preloads = {})
      # @type [Project]
      @project = project
      # @type [Array<Symbol>, Hash]
      @preloads = preloads
      # @type [Date]
      @month = month&.beginning_of_month || Time.zone.today.beginning_of_month
      start_preload_queries if @preloads.any?
    end

    private

    def product_statistics
      @product_statistics ||= ProjectStatistic::ByProductViewModel.new(@project, @month)
    end

    def page_statistics
      @page_statistics ||= ProjectStatistic::ByPageViewModel.new(@project, @month)
    end

    def start_preload_queries
      PRELOAD_QUERIES_SCHEMA.each do |preload, queries|
        next unless @preloads.include?(preload)

        queries = @preloads[preload] if @preloads.is_a?(Hash)
        queries.each { |query| send(query) }
      end
    end
  end
end
