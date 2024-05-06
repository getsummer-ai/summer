# frozen_string_literal: true

class ChangeProjectTypes < ActiveRecord::Migration[7.1]
  def change
    rename_enum_value :user_project_type, from: "paid", to: "light"
    add_enum_value :user_project_type, "pro", after: "light"
  end
end
