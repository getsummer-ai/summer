# frozen_string_literal: true

module ProjectSelector
  class Component < ViewComponent::Base
    include ViewComponent::UseHelpers

    def initialize(current_project:, projects:)
      super
      @current_project = current_project
      @projects = projects
    end
  end
end
