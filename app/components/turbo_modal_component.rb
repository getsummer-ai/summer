# frozen_string_literal: true


class TurboModalComponent < ViewComponent::Base
  include Turbo::FramesHelper

  def initialize(title:, go_back_path: nil, show_buttons: false, redirect_following: true)
    super
    @title = title
    @show_buttons = show_buttons
    @go_back_path = go_back_path
    @redirect_following = redirect_following
  end

end
