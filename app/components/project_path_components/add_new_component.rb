# frozen_string_literal: true

module ProjectPathComponents
  class AddNewComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    # @param [Project] project
    def initialize(project:)
      super
      @project = project
    end
  end
end

