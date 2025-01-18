# frozen_string_literal: true

module ProjectDomainAliasComponents
  class AddNewComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    # @param [Project] project
    # @param [String] dom_id
    # @param [String] class_name
    def initialize(project:, dom_id:, class_name: '')
      super
      @project = project
      @dom_id = dom_id
      @class_name = class_name
    end
  end
end

