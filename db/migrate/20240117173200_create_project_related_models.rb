# frozen_string_literal: true

class CreateProjectRelatedModels < ActiveRecord::Migration[7.1]
  def change
    create_enum "user_project_llm", %w[gpt3.5 gpt4]
    create_enum "user_project_status", %w[active suspended deleted]
    create_enum "user_project_type", %w[free paid]
    create_table :projects do |t|
      t.uuid :uuid, default: "gen_random_uuid()", null: false
      t.references :user, null: false, foreign_key: { on_update: :cascade }
      t.string :name, default: "", null: false
      t.string :domain, null: false
      t.enum :plan, default: "free", null: false, enum_type: "user_project_type"
      t.enum :status, default: "active", null: false, enum_type: "user_project_status"
      t.jsonb :settings
      t.enum :default_llm, default: "gpt3.5", null: false, enum_type: "user_project_llm"
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :projects, :uuid, unique: true
    add_index :projects, :created_at
    add_index :projects, [:user_id, :name], unique: true
    add_index :projects, [:user_id, :domain], unique: true


    create_table :project_urls do |t|
      t.references :project, null: false, index: true, foreign_key: { on_update: :cascade }
      t.string :url_hash, null: false
      t.string :url, null: false
      t.boolean :is_accessible, default: true, null: false
      t.timestamps
    end
    add_index :project_urls, [:project_id, :url_hash], unique: true

    create_enum "project_article_status", %w[in_queue processing summarized error skipped]
    create_table :project_articles do |t|
      t.references :project, null: false, index: true, foreign_key: true
      t.string :article_hash, null: false
      t.text :article, null: false
      t.integer :tokens_count, default: 0, null: false
      t.enum :status, default: "in_queue", null: false, enum_type: "project_article_status"
      t.jsonb :service_info
      t.text :title
      t.text :image_url
      t.datetime :last_modified
      t.text :summary
      t.enum :llm, enum_type: "user_project_llm"
      t.datetime :summarized_at
      t.timestamps
    end
    add_index :project_articles, [:project_id, :article_hash], unique: true


    create_table :project_article_urls do |t|
      t.references :project_article, null: false, index: true, foreign_key: { on_update: :cascade }
      t.references :project_url, null: false, index: true, foreign_key: { on_update: :cascade }
      t.timestamps
    end

    create_table :project_article_statistics do |t|
      t.references :project_article, null: false, index: true, foreign_key: { on_update: :cascade }
      t.references :project_url, null: false, index: true, foreign_key: { on_update: :cascade }
      t.date :date, null: false
      t.integer :hour, limit: 1, null: false
      t.bigint :views, default: 0, null: false
      t.bigint :clicks, default: 0, null: false
      t.timestamps
    end
    add_index :project_article_statistics, [:project_article_id, :project_url_id, :date, :hour], unique: true
    add_index :project_article_statistics, :date
  end
end
