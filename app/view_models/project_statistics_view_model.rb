# frozen_string_literal: true

class ProjectStatisticsViewModel
  PRELOAD_QUERIES_SCHEMA = {
    pages: %i[total_pages_statistics current_month_pages_statistics],
    actions: %i[total_action_statistics current_month_action_statistics],
  }.freeze

  # @param [Project] project
  # @param [Array<Symbol>, Hash] preloads
  def initialize(project, preloads = {})
    # @type [Project]
    @project = project
    # @type [Array<Symbol>, Hash]
    @preloads = preloads
    start_preload_queries if @preloads.any?
  end

  # @return [Integer]
  def total_pages_count
    total_pages_statistics.value
  end

  # @return [Integer]
  def current_month_new_pages_count
    current_month_pages_statistics.value || 0
  end

  # @return [Integer]
  def total_views_count
    total_action_statistics.value.dig(0, 0) || 0
  end

  # @return [Integer]
  def total_clicks_count
    total_action_statistics.value.dig(0, 1) || 0
  end

  # @return [Integer]
  def current_month_new_views_count
    current_month_action_statistics.value.dig(0, 0) || 0
  end

  # @return [Integer]
  def current_month_new_clicks_count
    current_month_action_statistics.value.dig(0, 1) || 0
  end

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
    @total_pages_statistics ||= @project.pages.async_count
  end

  # @return [ActiveRecord::Promise]
  def current_month_pages_statistics
    @current_month_pages_statistics ||=
      @project.pages.where(created_at: Time.now.utc.all_month).async_count
  end

  # @return [ActiveRecord::Promise]
  def total_action_statistics
    @total_action_statistics ||=
      begin
        columns = Arel.sql('SUM(views)::BIGINT, SUM(clicks)::BIGINT')
        @project.statistics.by_pages.group(:project_id).async_pluck(columns)
      end
  end

  # @return [ActiveRecord::Promise]
  def current_month_action_statistics
    @current_month_action_statistics ||=
      begin
        columns = Arel.sql('SUM(views)::BIGINT, SUM(clicks)::BIGINT')
        @project.statistics.by_pages.current_month.group(:project_id).async_pluck(columns)
      end
  end
end
