# frozen_string_literal: true
class AddDomainAliasToProjectsTable < ActiveRecord::Migration[7.1]
  def change
    add_column :projects, :domain_alias, :string, null: true
    add_index :projects, %i[user_id domain_alias], unique: true, where: "status <> 'deleted'"
  end
end
