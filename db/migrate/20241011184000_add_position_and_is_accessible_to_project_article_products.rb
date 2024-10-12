# frozen_string_literal: true
class AddPositionAndIsAccessibleToProjectArticleProducts < ActiveRecord::Migration[7.1]
  def change
    change_table :project_article_products, bulk: true do |t|
      t.integer :position, default: 10, null: false
      t.boolean :is_accessible, default: true, null: false
    end
  end
end
