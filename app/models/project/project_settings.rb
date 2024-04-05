# frozen_string_literal: true
class Project
  # @!attribute feature_suggestion
  #   @return [ProjectSuggestionFeature]
  # @!attribute feature_subscription
  #   @return [ProjectSubscriptionFeature]
  class ProjectSettings
    include StoreModel::Model

    attribute :container_id, :string
    attribute :appearance, ProjectAppearanceSettings.to_type, default: -> { {} }
    attribute :feature_suggestion, ProjectSuggestionFeature.to_type, default: -> { {} }
    attribute :feature_subscription, ProjectSubscriptionFeature.to_type, default: -> { {} }

    accepts_nested_attributes_for :feature_suggestion, :feature_subscription, :appearance,
      allow_destroy: false, update_only: true

    validates :appearance, store_model: { merge_errors: false }
    validates :feature_suggestion, store_model: { merge_errors: false }
    validates :feature_subscription, store_model: { merge_errors: false }

    validates :container_id,
              allow_blank: true,
              format: {
                with: /\A[a-zA-Z][\w:.-]*\z/,
                message: "Only html ID name is allowed. Example: 'article-container'",
              }
  end
end
