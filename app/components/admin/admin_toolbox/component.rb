# frozen_string_literal: true

module Admin
  module AdminToolbox
    class Component < ViewComponent::Base
      include ViewComponent::UseHelpers

      def initialize(true_user:, current_user:)
        super
        @current_user = current_user
        @true_user = true_user
      end
    end
  end
end
