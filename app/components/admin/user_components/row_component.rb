# frozen_string_literal: true

module Admin
  module UserComponents
    class RowComponent < ViewComponent::Base
      include ViewComponent::UseHelpers

      def initialize(user:)
        super
        @user = user
      end
    end
  end
end

