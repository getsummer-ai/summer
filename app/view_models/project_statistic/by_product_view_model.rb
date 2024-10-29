# frozen_string_literal: true
class ProjectStatistic
  class ByProductViewModel
    attr_reader :month

    # @param [Project] project
    # @param [Date] month
    def initialize(project, month = nil)
      # @type [Project]
      @project = project
      # @type [Date]
      @month = month&.beginning_of_month || Time.zone.today.beginning_of_month
    end

    def total_product_views
      products_total_statistics.value.dig(0, 0) || 0
    end

    private

    # @return [ActiveRecord::Promise]
    def products_total_statistics
      @products_total_statistics ||=
        @project
          .statistics_by_month
          .by_products
          .group(:project_id)
          .async_pluck(Arel.sql('SUM(views)::BIGINT, SUM(clicks)::BIGINT'))
    end
  end
end
