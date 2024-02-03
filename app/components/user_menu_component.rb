# frozen_string_literal: true


class UserMenuComponent < ViewComponent::Base
  include ViewComponent::UseHelpers

  def initialize(user:)
    super
    @user = user
  end
end
