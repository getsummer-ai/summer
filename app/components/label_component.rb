# frozen_string_literal: true

class LabelComponent < ViewComponent::Base
  include ViewComponent::UseHelpers

  def initialize(text:, is_big: false)
    @text = text
    @is_big = is_big
    super
  end
end
