# frozen_string_literal: true
module Actions
  class ActionCardComponent < ViewComponent::Base
    include ViewComponent::UseHelpers

    def initialize(title:, description: '', color: 'pink')
      @title = title
      @description = description
      @color = color

      super
    end
  end
end
