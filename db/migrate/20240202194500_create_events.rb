# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :category, null: false
      t.string :subcategory, null: false
      t.references :trackable, polymorphic: true, index: true
      t.string :source
      t.jsonb :details, null: false
      t.references :author, polymorphic: true, index: true
      t.references :project, index: false, foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.datetime :created_at, null: false
    end
    add_index :events, :created_at
    add_index :events, :source
    add_index :events, [:project_id, :source]
  end
end
