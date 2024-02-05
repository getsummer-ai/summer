# frozen_string_literal: true

class AddDefaultProjectToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.references :default_project,
                   index: true,
                   foreign_key: {
                     to_table: :projects,
                     on_delete: :nullify,
                     on_update: :cascade
                   }
    end
  end
end
