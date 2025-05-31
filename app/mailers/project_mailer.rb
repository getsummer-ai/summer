# frozen_string_literal: true
#
# Mailer that is responsible for sending emails related to project activities.
#
class ProjectMailer < MjmlMailer
  default reply_to: 'support@getsummer.ai'

  def out_of_clicks_suspension_notification(project_id)
    @project = Project.find(project_id).decorate

    plan = @project.subscription.plan || @project.plan
    mail to: @project.users.pluck(:email),
         subject: 'Your plan has run out of clicks',
         template_name: "#{plan}_plan_suspension_notification"
  end

  def added_user_invitation_email(project_user_id)
    @project_user = ProjectUser.find(project_user_id)
    @project = @project_user.project.decorate

    mail to: @project_user.email, subject: "You have been added to #{@project.name}"
  end
end
