# frozen_string_literal: true
class CreateEmailsAndEmailablesTables < ActiveRecord::Migration[7.1]
  def change
    create_table :emails, id: :uuid do |t|
      t.timestamps
      t.string :message_id, index: true
      t.string :to
      t.string :from
      t.string :subject
      t.text :mail, limit: 2.megabytes
      t.string :delivery_method
      t.string :mailer_name
      t.string :action_name
      t.datetime :sent_at
      t.integer :retries, limit: 2, default: 0
    end

    add_index :emails, :created_at

    create_table :emails_emailables do |t|
      t.references :email,
                   null: false,
                   index: true,
                   type: :uuid,
                   foreign_key: {
                     on_update: :cascade,
                     on_delete: :cascade,
                   }
      t.references :emailable, polymorphic: true, type: :string, index: true
      t.timestamps
    end
  end
end
