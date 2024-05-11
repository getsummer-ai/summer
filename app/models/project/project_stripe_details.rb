# frozen_string_literal: true
class Project
  # @!attribute customer_id
  #   @return [String]
  # @!attribute subscription
  #   @return [StripeSubscription]
  class ProjectStripeDetails
    include StoreModel::Model

    attribute :customer_id, :string, default: nil
    attribute :subscription, StripeSubscription.to_type, default: -> { {} }

    accepts_nested_attributes_for :subscription, allow_destroy: false, update_only: true

    validates :subscription, store_model: { merge_errors: false }
  end
end
