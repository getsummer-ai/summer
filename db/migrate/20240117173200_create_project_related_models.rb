# frozen_string_literal: true

class CreateProjectRelatedModels < ActiveRecord::Migration[7.1]
  def change
    create_enum 'user_project_llm', %w[gpt3.5 gpt4]
    create_enum 'user_project_status', %w[active suspended deleted]
    create_enum 'user_project_type', %w[free paid]
    create_enum 'user_project_protocol', %w[http https]
    create_table :projects do |t|
      t.timestamps
      t.references :user, null: false, foreign_key: { on_update: :cascade }
      t.string :name, default: '', null: false
      t.string :protocol, null: false, enum_type: 'user_project_protocol'
      t.string :domain, null: false
      t.jsonb :paths, default: '[]', null: false
      t.jsonb :settings
      t.enum :status, default: 'active', null: false, enum_type: 'user_project_status'
      t.datetime :deleted_at
      t.enum :plan, default: 'free', null: false, enum_type: 'user_project_type'
      t.enum :default_llm, default: "gpt3.5", null: false, enum_type: 'user_project_llm'
      # t.uuid :uuid, default: 'gen_random_uuid()', null: false
      t.text :guidelines, default: ''
    end
    # add_index :projects, :uuid, unique: true
    add_index :projects, :created_at
    add_index :projects, %i[user_id name], unique: true, where: "status <> 'deleted'"
    add_index :projects, %i[user_id domain], unique: true, where: "status <> 'deleted'"

    create_table :project_articles do |t|
      t.timestamps
      t.references :project, null: false, index: true, foreign_key: true
      t.string :article_hash, null: false
      t.text :title
      t.text :article, null: false
      t.integer :tokens_count, default: 0, null: false
      t.text :image_url
      t.datetime :last_modified_at
      t.datetime :last_scraped_at
      t.jsonb :info
    end
    add_index :project_articles, %i[project_id article_hash], unique: true

    create_table :project_pages do |t|
      t.timestamps
      t.references :project, null: false, index: true, foreign_key: { on_update: :cascade }
      t.string :url_hash, null: false
      t.string :url, null: false
      t.boolean :is_accessible, default: true, null: false
      t.references :project_article, null: false, index: true, foreign_key: { on_update: :cascade }
    end
    add_index :project_pages, %i[project_id url_hash], unique: true
    add_index :project_pages, %i[project_id url], unique: true

    create_table :project_statistics do |t|
      t.timestamps
      t.references :trackable, polymorphic: true, index: true
      # t.references :project_article, null: false, index: true, foreign_key: { on_update: :cascade }
      t.references :project, null: false, foreign_key: { on_update: :cascade }
      t.date :date, null: false
      t.integer :hour, limit: 1, null: false
      t.bigint :views, default: 0, null: false
      t.bigint :clicks, default: 0, null: false
    end
    add_index :project_statistics,
              %i[project_id trackable_type trackable_id date hour],
              unique: true
    add_index :project_statistics, [:project_id, :date]
  end
end
