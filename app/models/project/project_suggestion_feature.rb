# frozen_string_literal: true
class Project
  class ProjectSuggestionFeature
    include StoreModel::Model

    attribute :enabled, :boolean, default: true
    
    validates :enabled, inclusion: { in: [true, false] }
  end
end
