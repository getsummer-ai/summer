# frozen_string_literal: true

module ProjectPageComponents
  class RowComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    def initialize(project:, page:, link:)
      super
      @project = project
      @page = page
      @link = link
    end
  end
end

