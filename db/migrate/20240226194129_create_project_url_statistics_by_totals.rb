class CreateProjectUrlStatisticsByTotals < ActiveRecord::Migration[7.1]
  def change
    create_view :project_url_statistics_by_totals
  end
end
