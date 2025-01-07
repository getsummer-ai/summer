# frozen_string_literal: true
class CreateProjectServices < ActiveRecord::Migration[7.1]
  def change
    create_table :project_products do |t|
      t.timestamps
      t.references :project,
                   null: false,
                   index: true,
                   foreign_key: {
                     on_update: :cascade,
                     on_delete: :cascade,
                   }
      t.string :name, null: false
      t.string :description, null: false
      t.string :link, null: false
      t.jsonb :info
      t.binary :icon
      t.boolean :is_accessible, default: true, null: false
      t.uuid :uuid, default: 'gen_random_uuid()', null: false
    end
    add_index :project_products, :uuid, unique: true
    add_index :project_products, %i[project_id uuid]

    change_table :project_articles do |t|
      t.enum :products_status, default: 'wait', null: false, enum_type: 'project_article_feature_status'
      t.references :products_llm_call, index: true, foreign_key: { to_table: :project_llm_calls }
    end

    create_table :project_article_products do |t|
      t.datetime :created_at, null: false
      t.references :project_article,
                   null: false,
                   index: true,
                   foreign_key: {
                     on_update: :cascade,
                     on_delete: :cascade,
                   }
      t.references :project_product,
                   null: false,
                   index: true,
                   foreign_key: {
                     on_update: :cascade,
                     on_delete: :cascade,
                   }
    end
    add_index :project_article_products, [:project_article_id, :project_product_id], unique: true
  end
end
