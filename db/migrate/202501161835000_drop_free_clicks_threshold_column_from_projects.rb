# frozen_string_literal: true
class DropFreeClicksThresholdColumnFromProjects < ActiveRecord::Migration[7.1]
  def change
    remove_column \
      :projects,
      :free_clicks_threshold,
      :integer,
      default: 0, null: false
  end
end
