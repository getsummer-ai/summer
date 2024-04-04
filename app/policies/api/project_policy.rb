# frozen_string_literal: true
module Api
  # @!attribute [r] record
  #  @return [Project]
  class ProjectPolicy < ApplicationPolicy
    def use_button?
      return true if record.status_active?
      set_error_message('The button has been suspended') and false
    end

    def use_suggestion_feature?
      return true if record.settings.feature_suggestion.enabled
      set_error_message('The products feature is disabled for the project') and false
    end

    def use_subscription_feature?
      return true if record.settings.feature_subscription.enabled
      set_error_message('The subscription feature is disabled for the project') and false
    end
  end
end

