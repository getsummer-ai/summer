# frozen_string_literal: true
class Project
  class ProjectPath
    class Statistics
      # @param [Project] project
      # @param [ProjectPath. nil] path
      def initialize(project, path: nil)
        # @type [Project]
        @project = project
        # @type [ProjectPath. nil]
        @path = path
      end

      # @return [Array<StatisticViewModel>]
      def result
        return @result if @result
        paths = @project.smart_paths
        paths = paths.filter { |p| p.id == @path.id } if @path.present?
        @result = paths.map { |project_path| calculate_statistic(project_path) }
      end

      private

      # @param [Project::ProjectPath] project_path
      # @return [StatisticViewModel]
      def calculate_statistic(project_path)
        result =
          ProjectStatisticsByTotal
            .where(
              project_id: @project.id,
              trackable_id: project_path.project_page_ids_query,
              trackable_type: ProjectPage.name,
            )
            .group(:project_id)
            .pluck(Arel.sql('COUNT(*)::BIGINT, SUM(views)::BIGINT, SUM(clicks)::BIGINT'))

        StatisticViewModel.new(
          project_path,
          pages: result.dig(0, 0) || 0,
          views: result.dig(0, 1) || 0,
          clicks: result.dig(0, 2) || 0,
        )
      end
    end
  end
end
