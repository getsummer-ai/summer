# frozen_string_literal: true

module ProjectProductComponents
  class RowComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    # @param [ProjectProduct] product
    def initialize(product:)
      super
      @product = product
    end
  end
end

