# frozen_string_literal: true

module ProjectPathComponents
  class DestroyButtonComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    # @param [ProjectPath] project_path
    def initialize(project_path:)
      super
      @project_path = project_path
    end
  end
end

