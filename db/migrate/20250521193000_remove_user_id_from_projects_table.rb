# frozen_string_literal: true
class RemoveUserIdFromProjectsTable < ActiveRecord::Migration[7.1]
  def change
    remove_index :projects, :user_id
    remove_index :projects, %i[user_id name]
    remove_index :projects, %i[user_id domain]
    remove_index :projects, %i[user_id domain_alias]
    remove_column :projects, :user_id, if_exists: true
  end
end
