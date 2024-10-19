# frozen_string_literal: true
class CreateProjectUrlStatisticsByMonths < ActiveRecord::Migration[7.1]
  def change
    create_view :project_statistics_by_months
  end
end
