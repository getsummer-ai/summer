# frozen_string_literal: true
class AddProjectApiKeysTable < ActiveRecord::Migration[7.1]
  def change
    create_enum "project_api_key_type", %w[default framer]

    create_table :project_api_keys, id: :uuid do |t|
      t.datetime :created_at, null: false
      t.datetime :activated_at
      t.datetime :expired_at
      t.enum :key_type, default: 'default', null: false, enum_type: "project_api_key_type"
      t.jsonb :details, default: {}, null: false
      t.references :project, foreign_key: true
      t.references :owner, foreign_key: { to_table: :users }
      t.integer :usage_count, default: 0, null: false
      t.datetime :last_used_at
    end
  end
end
