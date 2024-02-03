# frozen_string_literal: true

class ProjectSelectorComponent < ViewComponent::Base
  include ViewComponent::UseHelpers

  def initialize(current_project:, projects:)
    super
    @current_project = current_project
    @projects = projects
  end
end
