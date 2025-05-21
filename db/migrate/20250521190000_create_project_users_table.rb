# frozen_string_literal: true
class CreateProjectUsersTable < ActiveRecord::Migration[7.1]
  def change
    create_enum 'project_user_role', %w[admin viewer]

    create_table :project_users do |t|
      t.timestamps
      t.references :project,
                   null: false,
                   foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.references :user,
        null: true,
        foreign_key: { on_update: :cascade, on_delete: :cascade }
      t.enum :role, default: 'admin', null: false, enum_type: 'project_user_role'
      t.string :invited_email_address
      t.datetime :invitation_sent_at
    end

    add_index :project_users, %i[user_id project_id], unique: true
  end
end
