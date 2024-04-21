# frozen_string_literal: true
class ProjectMailerPreview < ActionMailer::Preview
  def suspension_notification
    ProjectMailer.suspension_notification(Project.first.id)
  end
end
