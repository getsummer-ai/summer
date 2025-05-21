# frozen_string_literal: true
class TransferUserIdsFromProjectsTable < ActiveRecord::Migration[7.1]
  def up
    Project.find_each do |project|
      ProjectUser.find_or_create_by(project_id: project.id, user_id: project.user_id) do |project_user|
        project_user.role = 'admin'
      end
    end
  end

  def down
  end
end
