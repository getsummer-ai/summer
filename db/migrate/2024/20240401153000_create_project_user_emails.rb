# frozen_string_literal: true
class CreateProjectUserEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :project_user_emails do |t|
      t.timestamps
      t.references :project,
                   null: false,
                   index: false,
                   foreign_key: {
                     on_update: :cascade,
                     on_delete: :cascade,
                   }
      t.references :project_page,
                   null: false,
                   index: false,
                   foreign_key: {
                    on_update: :cascade,
                    on_delete: :cascade,
                   }
      t.string :email, null: false
      t.string :encrypted_page_id, null: false
      t.uuid :uuid, default: 'gen_random_uuid()', null: false
    end
    add_index :project_user_emails, :uuid, unique: true
    add_index :project_user_emails, :encrypted_page_id, unique: true
    add_index :project_user_emails, [:project_id, :email], unique: true
  end
end
