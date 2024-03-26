# frozen_string_literal: true
class CreateProjectArticleSummaries < ActiveRecord::Migration[7.1]
  def change
    create_table :project_article_summaries do |t|
      t.timestamps
      t.references :project_article,
                   null: false,
                   index: true,
                   foreign_key: {
                     on_update: :cascade,
                     on_delete: :cascade,
                   }
      t.jsonb :info, default: {}, null: false
      t.integer :in_tokens_count, default: 0, null: false
      t.text :input
      t.enum :llm, null: false, enum_type: 'user_project_llm'
      t.integer :out_tokens_count, default: 0, null: false
      t.text :summary
    end

    create_enum 'project_article_common_status', %w[error skipped wait processing completed static]

    change_table :project_articles do |t|
      t.enum :status_summary, default: 'wait', null: false, enum_type: 'project_article_common_status'
    end
  end
end
