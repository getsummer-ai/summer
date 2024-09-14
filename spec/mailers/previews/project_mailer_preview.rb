# frozen_string_literal: true
class ProjectMailerPreview < ActionMailer::Preview
  def suspension_notification_free_plan
    ProjectMailer.suspension_notification(Project.where(plan: 'free').first.id)
  end

  def suspension_notification_light_plan
    ProjectMailer.suspension_notification(Project.where(plan: 'light').first.id)
  end

  def suspension_notification_pro_plan
    ProjectMailer.suspension_notification(Project.where(plan: 'pro').first.id)
  end
end
