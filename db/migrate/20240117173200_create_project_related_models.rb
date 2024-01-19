# frozen_string_literal: true

class CreateProjectRelatedModels < ActiveRecord::Migration[7.1]
  def change
    # 	+ projects (id: uuid, user_id, name, domain, plan: (free, paid),
    #     settings(json), status(active, suspended, deleted), created_at, updated_at, deleted_at)
    # 		(created_at - index) user_id - FK
    create_enum "user_project_status", %w[active suspended deleted]
    create_enum "user_project_type", %w[free paid]
    create_table :projects, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, default: "", null: false
      t.string :domain, null: false
      t.enum :plan, default: "free", null: false, enum_type: "user_project_type"
      t.enum :status, default: "active", null: false, enum_type: "user_project_status"
      t.jsonb :settings
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :projects, :created_at
    add_index :projects, [:user_id, :name], unique: true
    add_index :projects, [:user_id, :domain], unique: true


    #   	+ project_urls (id: int, project_id, hash:string, url: string, created_at)
    # 		(project_id - FK, hash - unique index)
    create_table :project_urls do |t|
      t.references :project, null: false, index: true, foreign_key: true, type: :uuid
      t.string :url_hash, null: false
      t.string :url, null: false
      t.datetime :created_at, null: false
    end
    add_index :project_urls, [:project_id, :url_hash], unique: true

    # 	+ project_articles (id: int, project_id, title, title_hash: string, article: text,
    #     article_hash: string, summary: text, created_at, updated_at)
    # 		project_id - fk, project + title_hash
    create_table :project_articles do |t|
      t.references :project, null: false, index: true, foreign_key: true, type: :uuid

      t.text :title, default: "", null: false
      t.string :title_hash
      t.text :article, null: false
      t.string :article_hash, null: false
      t.text :summary
      t.boolean :is_summarized, default: false, null: false
      t.timestamps
    end
    add_index :project_articles, [:project_id, :article_hash], unique: true

    #   	+ project_article_urls (article_id: int, url_id: int)
    # 		(article_id + url_id - PK)
    create_table :project_article_urls do |t|
      t.references :project_article, null: false, index: true, foreign_key: true
      t.references :project_url, null: false, index: true, foreign_key: true
      t.timestamps
    end

    # 	+ project_article_statistic(id, article_id, project_url_id, date, views, clicks, created_at, updated_at)
    # 		(article_id + date + project_url_id  - unique index) date - index, article_id - fk, project_url_id - fk
    create_table :project_article_statistics do |t|
      t.references :project_article, null: false, index: true, foreign_key: true
      t.references :project_url, null: false, index: true, foreign_key: true
      t.date :date, null: false
      t.bigint :views, default: 0, null: false
      t.bigint :clicks, default: 0, null: false
      t.timestamps
    end
    add_index :project_article_statistics, [:project_article_id, :date, :project_url_id], unique: true
    add_index :project_article_statistics, :date
  end
end
