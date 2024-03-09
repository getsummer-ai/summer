# frozen_string_literal: true
class CreateProjectServices < ActiveRecord::Migration[7.1]
  def change
    create_table :project_services do |t|
      t.timestamps
      t.references :project,
                   null: false,
                   index: true,
                   foreign_key: {
                     on_update: :cascade,
                     on_delete: :cascade,
                   }
      t.string :title, null: false
      t.string :description, null: false
      t.string :link, null: false
      t.uuid :uuid, default: 'gen_random_uuid()', null: false, index: true
    end

    change_table :project_articles do |t|
      t.enum :status_services, default: 'wait', null: false, enum_type: 'project_article_common_status'
    end

    create_table :project_article_services do |t|
      t.datetime :created_at, null: false
      t.references :project_article,
                   null: false,
                   index: true,
                   foreign_key: {
                     on_update: :cascade,
                     on_delete: :cascade,
                   }
      t.references :project_service,
                   null: false,
                   index: true,
                   foreign_key: {
                     on_update: :cascade,
                     on_delete: :cascade,
                   }
    end
    add_index :project_article_services, [:project_article_id, :project_service_id], unique: true
  end
end
