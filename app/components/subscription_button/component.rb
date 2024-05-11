# frozen_string_literal: true

module SubscriptionButton
  class Component < ViewComponent::Base
    # include ViewComponent::UseHelpers

    def initialize(project:, button_classes: '')
      super
      @project = project
      @button_classes = button_classes
    end
  end
end
