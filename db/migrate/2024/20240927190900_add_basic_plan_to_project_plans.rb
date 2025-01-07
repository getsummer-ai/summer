# frozen_string_literal: true

class AddBasicPlanToProjectPlans < ActiveRecord::Migration[7.1]
  def change
    add_enum_value :user_project_type, "basic", after: "free"
  end
end
