# frozen_string_literal: true

module Setup
  class AppearanceComponent < ViewComponent::Base
    include ViewComponent::UseHelpers

    def initialize(project_appearance_settings:)
      super
      # @type [Project::ProjectAppearanceSettings]
      @project_appearance_settings = project_appearance_settings
    end
  end
end
