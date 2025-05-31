# frozen_string_literal: true

module ProjectUserComponents
  class RowComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    # @param [ProjectUser] project_user
    def initialize(project_user:)
      super
      @project_user = project_user
    end
  end
end
