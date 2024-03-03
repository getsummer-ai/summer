# frozen_string_literal: true

module ProjectPageComponents
  class RowComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    def initialize(project:, page:)
      super
      @project = project
      @page = page
    end
  end
end

