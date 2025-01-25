# frozen_string_literal: true
class AddIsPrimaryDomainToProjectPageTable < ActiveRecord::Migration[7.1]
  def change
    add_column :project_pages, :is_primary_domain, :boolean, null: false, default: true
  end
end
