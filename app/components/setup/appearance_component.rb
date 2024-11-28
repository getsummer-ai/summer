# frozen_string_literal: true

module Setup
  class AppearanceComponent < ViewComponent::Base
    include ViewComponent::UseHelpers

    def initialize(project:)
      super
      @project = project
    end
  end
end
