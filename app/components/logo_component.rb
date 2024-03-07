# frozen_string_literal: true

class LogoComponent < ViewComponent::Base
  include ViewComponent::UseHelpers

  def initialize(color: 'black')
    @color = color
    super
  end
end
