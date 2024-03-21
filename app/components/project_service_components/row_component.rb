# frozen_string_literal: true

module ProjectServiceComponents
  class RowComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    # @param [ProjectService] service
    def initialize(service:)
      super
      @service = service
    end
  end
end

