# frozen_string_literal: true

module ProjectProductComponents
  class AddNewComponent < ViewComponent::Base
    include ViewComponent::UseHelpers

    # @param [Project] project
    def initialize(project:)
      super
      @project = project
    end
  end
end

