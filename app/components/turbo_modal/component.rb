# frozen_string_literal: true

module TurboModal
  class Component < ViewComponent::Base
    include Turbo::FramesHelper

    def initialize(
      title:,
      go_back_path: nil,
      redirect_following: true,
      allow_hash_changes: true,
      size: 'sm'
    )
      super
      @title = title
      @go_back_path = go_back_path
      @redirect_following = redirect_following
      @allow_hash_changes = allow_hash_changes
      @size = size
    end
  end
end
