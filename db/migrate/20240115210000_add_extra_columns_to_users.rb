# frozen_string_literal: true
class AddExtraColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    create_enum "user_locale", %w[en es]

    change_table :users, bulk: true do |t|
      t.string :provider
      t.string :uid
      t.enum :locale, default: "en", null: false, enum_type: "user_locale"
      t.boolean :is_admin, default: false, null: false
      t.datetime :deleted_at
    end
  end
end
