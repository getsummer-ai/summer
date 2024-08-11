# frozen_string_literal: true

class AddClicksThresholdToProject < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :free_clicks_threshold, :integer, default: 500, null: false
  end
end
