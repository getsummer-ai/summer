# frozen_string_literal: true

module ProjectPathComponents
  class RowComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    # @param [Project] project
    # @param [Project::ProjectPath::StatisticViewModel] statistic_view_model
    def initialize(project:, statistic_view_model:)
      super
      @project = project
      @statistic_view_model = statistic_view_model
    end
  end
end

