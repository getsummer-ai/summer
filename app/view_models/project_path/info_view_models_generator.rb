# frozen_string_literal: true
module ProjectPath
  class InfoViewModelsGenerator
    # @param [Project] project
    def initialize(project)
      # @type [Project]
      @project = project
      # @type [Array<String>]
      @urls = @project.paths.map { |path| "#{@project.protocol}://#{@project.domain}#{path}" }
    end

    def result
      @result ||= @urls.map { |url, index| calculate_statistic(url, index) }
    end

    private

    # @param [String] url
    # @param [Integer] index
    # @return [InfoViewModel]
    def calculate_statistic(url, index)
      ids_query = @project.pages.select('id').where("url LIKE ?", "#{url}%")
      columns = Arel.sql('COUNT(*)::BIGINT, SUM(views)::BIGINT, SUM(clicks)::BIGINT')
      result =
        ProjectStatisticsByTotal
          .where(project_id: @project.id, trackable_id: ids_query, trackable_type: ProjectPage.name)
          .group(:project_id)
          .pluck(columns)
      pages_count = result.dig(0, 0) || 0
      pages_views = result.dig(0, 1) || 0
      pages_clicks = result.dig(0, 2) || 0

      InfoViewModel.new(id: index, url:, pages: pages_count, views: pages_views, clicks: pages_clicks)
    end
  end
end
