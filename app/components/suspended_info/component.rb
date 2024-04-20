# frozen_string_literal: true

module SuspendedInfo
  class Component < ViewComponent::Base
    include Turbo::FramesHelper

    def initialize(project:)
      super
      # @type [Project]
      @project = project
    end
  end
end

