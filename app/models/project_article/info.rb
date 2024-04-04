# frozen_string_literal: true
class ProjectArticle
  # @!attribute summary
  #   @return [Hash]
  # @!attribute products
  #   @return [Hash]
  class Info
    include StoreModel::Model
    attribute :summary, default: -> { {} }
    attribute :products, default: -> { {} }
  end
end
