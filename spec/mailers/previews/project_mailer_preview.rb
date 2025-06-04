# frozen_string_literal: true
class ProjectMailerPreview < ActionMailer::Preview
  def suspension_notification_free_plan
    ProjectMailer.out_of_clicks_suspension_notification(334)
  end

  def suspension_notification_light_plan
    ProjectMailer.out_of_clicks_suspension_notification(Project.where(plan: 'light').first.id)
  end

  def suspension_notification_pro_plan
    ProjectMailer.out_of_clicks_suspension_notification(Project.where(plan: 'pro').first.id)
  end

  def added_user_invitation_email
    ProjectMailer.added_user_invitation_email(ProjectUser.take.id)
  end
end
