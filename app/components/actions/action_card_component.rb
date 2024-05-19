# frozen_string_literal: true
module Actions
  class ActionCardComponent < ViewComponent::Base
    include ViewComponent::UseHelpers

    def initialize(title:, description: '', color: 'pink', link: nil)
      @title = title
      @description = description
      @color = color
      @link = link

      super
    end
  end
end
