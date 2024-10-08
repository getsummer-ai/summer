# frozen_string_literal: true
class AddDateHourColumnToStatistics < ActiveRecord::Migration[7.1]
  def up
    add_column :project_statistics, :date_hour, :timestamp, precision: 0

    execute <<-SQL.squish
      UPDATE project_statistics
      SET date_hour = (CAST(date AS TIMESTAMP) + (hour || ':00:00')::INTERVAL)::TIMESTAMP(0);
    SQL

    change_column_null :project_statistics, :date_hour, false

    add_index :project_statistics,
              %i[project_id trackable_type trackable_id date_hour],
              unique: true

    add_index :project_statistics, %i[project_id date_hour]
  end

  def down
    remove_column :project_statistics, :date_hour
  end
end
