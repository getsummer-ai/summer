# frozen_string_literal: true

module ProjectPathComponents
  class RowComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    # @param [Project] project
    # @param [ProjectPath::InfoViewModel] path_info
    def initialize(project:, path_info:)
      super
      @project = project
      @path_info = path_info
    end
  end
end

