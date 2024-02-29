# frozen_string_literal: true

class ProjectPageRowComponent < ViewComponent::Base
  include ViewComponent::UseHelpers
  include ActiveSupport::NumberHelper

  def initialize(project:, page:, has_top_border: false)
    super
    @project = project
    @page = page
    @has_top_border = has_top_border
  end
end
