# frozen_string_literal: true
class RenameEmailsEmailablesTableEmailRelatedModels < ActiveRecord::Migration[7.1]
  def up
    rename_column :emails_emailables, :emailable_type, :model_type
    rename_column :emails_emailables, :emailable_id, :model_id
    rename_table :emails_emailables, :email_related_models
  end

  def down
    rename_table :email_related_models, :emails_emailables
    rename_column :email_related_models, :model_type, :emailable_type
    rename_column :email_related_models, :model_id, :emailable_id
  end
end
