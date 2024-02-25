# frozen_string_literal: true

class ProjectPageRowComponent < ViewComponent::Base
  include ViewComponent::UseHelpers

  def initialize(project:, project_url:, has_top_border: false)
    super
    @project = project
    @project_url = project_url
    @has_top_border = has_top_border
  end
end
