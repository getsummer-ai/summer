# frozen_string_literal: true
class Project
  # @!attribute cancel_at
  # @return [Integer]
  class StripeSubscription
    include StoreModel::Model

    attribute :id, :string
    attribute :start_date, :integer
    attribute :cancel_at, :integer
    attribute :canceled_at, :integer
    attribute :status, :string
    attribute :latest_invoice, :string

    attribute :plan_id, :string
    attribute :plan_interval, :string
  end
end
