# frozen_string_literal: true
class UpdateDefaultUserRoleForProjectOwners < ActiveRecord::Migration[7.1]
  def up
    Project.find_each do |p|
      ProjectUser.where(project_id: p.id).order(id: :asc).limit(1).update(role: :owner)
    end
  end

  def down
    Project.find_each do |p|
      ProjectUser.where(project_id: p.id).order(id: :asc).limit(1).update(role: :admin)
    end
  end
end
