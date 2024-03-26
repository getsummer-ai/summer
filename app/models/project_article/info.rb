# frozen_string_literal: true
class ProjectArticle
  # @!attribute summary
  #   @return [Hash]
  # @!attribute services
  #   @return [Hash]
  class Info
    include StoreModel::Model
    attribute :summary, default: -> { {} }
    attribute :services, default: -> { {} }
  end
end
