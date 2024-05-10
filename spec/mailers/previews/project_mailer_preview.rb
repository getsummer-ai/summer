# frozen_string_literal: true
class ProjectMailerPreview < ActionMailer::Preview
  def suspension_notification_free_plan
    ProjectMailer.suspension_notification(Project.first.id)
  end

  def suspension_notification_light_plan
    ProjectMailer.suspension_notification(Project.first.id, :light)
  end

  def suspension_notification_pro_plan
    ProjectMailer.suspension_notification(Project.first.id, :pro)
  end
end
