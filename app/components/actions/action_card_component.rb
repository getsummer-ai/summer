# frozen_string_literal: true
module Actions
  class ActionCardComponent < ViewComponent::Base
    include ViewComponent::UseHelpers

    def initialize(title:, icon:, description: '', color: 'pink', link: nil)
      @title = title
      @description = description
      @color = color
      @link = link
      @icon = icon

      super
    end
  end
end
