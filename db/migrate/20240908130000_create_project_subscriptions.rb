# frozen_string_literal: true
class CreateProjectSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :project_subscriptions do |t|
      t.timestamps
      t.references :project,
                   null: false,
                   index: true,
                   foreign_key: {
                   on_update: :cascade,
                   on_delete: :cascade,
                   }
      t.enum :plan, null: false, enum_type: 'user_project_type'
      t.datetime :start_at, precision: 0, null: false
      t.datetime :end_at, precision: 0, null: false
      t.datetime :cancel_at, precision: 0
      t.jsonb :stripe, default: {}, null: false
      t.integer :summarize_usage, null: false
      t.integer :summarize_limit, null: false
    end

    add_index :project_subscriptions, %i[project_id start_at end_at], unique: true

    change_table :projects do |t|
      t.references :subscription,
                   index: true,
                   foreign_key: {
                   to_table: :project_subscriptions,
                   on_delete: :restrict,
                   on_update: :cascade,
                   }
    end
  end
end
