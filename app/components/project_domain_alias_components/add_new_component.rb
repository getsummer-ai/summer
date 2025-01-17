# frozen_string_literal: true

module ProjectDomainAliasComponents
  class AddNewComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    # @param [Project] project
    # @param [String] dom_id
    def initialize(project:, dom_id:)
      super
      @project = project
      @dom_id = dom_id
    end
  end
end

