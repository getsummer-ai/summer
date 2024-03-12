# frozen_string_literal: true

module Notice
  class Component < ViewComponent::Base
    include Turbo::FramesHelper

    def initialize(container_class: '')
      @container_class = container_class
      super
    end
  end
end

