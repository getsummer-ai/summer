# frozen_string_literal: true
class AddIsPrimaryDomainToProjectPageTable < ActiveRecord::Migration[7.1]
  def change
    create_enum "project_admin_key_origin", %w[framer]

    create_table :project_admin_keys, id: :uuid do |t|
      t.datetime :created_at, null: false
      t.datetime :expired_at, null: false
      t.enum :origin, default: "framer", null: false, enum_type: "project_admin_key_origin"
      t.references :project, foreign_key: true
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.boolean :is_active, default: false, null: false
      t.integer :usage_count, default: 0, null: false
      t.datetime :last_used_at
    end
  end
end
