# frozen_string_literal: true

class ProjectPageRowComponent < ViewComponent::Base
  include ViewComponent::UseHelpers

  def initialize(project_url:, has_top_border: false)
    super
    @project_url = project_url
    @has_top_border = has_top_border
  end
end
