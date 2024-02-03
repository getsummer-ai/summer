# frozen_string_literal: true

class ProjectMenuComponent < ViewComponent::Base
  include ViewComponent::UseHelpers

  def initialize(project:)
    super
    @project = project
  end
end
