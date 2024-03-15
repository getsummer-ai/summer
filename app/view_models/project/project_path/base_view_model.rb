# frozen_string_literal: true
class Project
  class ProjectPath
    class BaseViewModel
      attr_reader :project_path

      # @param [ProjectPath] project_path
      def initialize(project_path)
        @project_path = project_path
      end
    end
  end
end
