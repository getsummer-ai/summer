# frozen_string_literal: true

class UpdateProjectLlmEnumValues < ActiveRecord::Migration[7.1]
  def up
    add_enum_value :user_project_llm, "gpt-4.1", after: "gpt-4o-mini"
    add_enum_value :user_project_llm, "gpt-4.1-mini", after: "gpt-4.1"
    add_enum_value :user_project_llm, "gpt-4.1-nano", after: "gpt-4.1-mini"
  end

  def down
    execute <<-SQL
      DELETE FROM pg_enum
      WHERE enumlabel = 'gpt-4.1-nano' AND enumtypid = 'user_project_llm'::regtype::oid;
    SQL
    execute <<-SQL
      DELETE FROM pg_enum
      WHERE enumlabel = 'gpt-4.1-mini' AND enumtypid = 'user_project_llm'::regtype::oid;
    SQL
    execute <<-SQL
      DELETE FROM pg_enum
      WHERE enumlabel = 'gpt-4.1' AND enumtypid = 'user_project_llm'::regtype::oid;
    SQL
  end
end
