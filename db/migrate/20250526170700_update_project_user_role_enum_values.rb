# frozen_string_literal: true

class UpdateProjectUserRoleEnumValues < ActiveRecord::Migration[7.1]
  def up
    add_enum_value :project_user_role, "owner", before: "admin"
  end

  def down
    execute <<-SQL
      DELETE FROM pg_enum
      WHERE enumlabel = 'owner' AND enumtypid = 'project_user_role'::regtype::oid;
    SQL
  end
end
