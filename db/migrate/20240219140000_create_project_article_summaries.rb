# frozen_string_literal: true
class CreateProjectArticleSummaries < ActiveRecord::Migration[7.1]
  def change
    create_enum 'project_llm_call_service_name', %w[summary products default]

    create_table :project_llm_calls do |t|
      t.timestamps
      t.references :project,
                   null: false,
                   index: true,
                   foreign_key: {
                     on_update: :cascade,
                     on_delete: :cascade,
                   }
      t.references :initializer, polymorphic: true, index: true
      t.enum :feature, default: 'default', null: false, enum_type: 'project_llm_call_service_name'
      t.jsonb :info, default: {}, null: false
      t.integer :in_tokens_count, default: 0, null: false
      t.text :input
      t.enum :llm, null: false, enum_type: 'user_project_llm'
      t.integer :out_tokens_count, default: 0, null: false
      t.text :output
    end

    add_index :project_llm_calls, %i[initializer_type initializer_id feature]
    create_enum 'project_article_feature_status', %w[error skipped wait processing completed static]

    change_table :project_articles do |t|
      t.enum :summary_status, default: 'wait', null: false, enum_type: 'project_article_feature_status'
      t.references :summary_llm_call, index: true, foreign_key: { to_table: :project_llm_calls }
    end
  end
end
