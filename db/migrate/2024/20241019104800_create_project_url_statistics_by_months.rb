# frozen_string_literal: true
class CreateProjectUrlStatisticsByMonths < ActiveRecord::Migration[7.1]
  def change
    create_view :project_statistics_by_months, materialized: true

    add_index :project_statistics_by_months, %i[trackable_type trackable_id month], unique: true
    add_index :project_statistics_by_months, %i[project_id trackable_type trackable_id month]
    add_index :project_statistics_by_months, %i[project_id month]
  end
end
