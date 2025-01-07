# frozen_string_literal: true

class AddEnterprisePlanToProjectPlans < ActiveRecord::Migration[7.1]
  def change
    add_enum_value :user_project_type, "enterprise", after: "pro"
  end
end
