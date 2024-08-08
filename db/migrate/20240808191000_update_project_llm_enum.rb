# frozen_string_literal: true

class UpdateProjectLlmEnum < ActiveRecord::Migration[7.1]
  def change
    add_enum_value :user_project_llm, "gpt-4o-mini", after: "gpt4"
    rename_enum_value :user_project_llm, from: "gpt4", to: "gpt-4o"
    rename_enum_value :user_project_llm, from: "gpt3.5", to: "gpt-3.5-turbo"
  end
end
