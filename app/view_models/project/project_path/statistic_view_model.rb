# frozen_string_literal: true
class Project
  class ProjectPath
    class StatisticViewModel < BaseViewModel
      attr_reader :pages, :views, :clicks

      # @param [ProjectPath] project_path
      # @param [Integer] pages
      # @param [Integer] views
      # @param [Integer] clicks
      def initialize(project_path, pages:, views:, clicks:)
        super(project_path)
        @pages = pages
        @views = views
        @clicks = clicks
      end
    end
  end
end
