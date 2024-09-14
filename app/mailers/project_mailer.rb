# frozen_string_literal: true
#
# Mailer that is responsible for sending emails related to project activities.
#
class ProjectMailer < MjmlMailer
  default reply_to: 'support@getsummer.ai'

  def out_of_clicks_suspension_notification(project_id)
    @project = Project.find(project_id).decorate

    plan = @project.subscription.plan || @project.plan
    mail to: @project.user.email,
         subject:  'Reactivate Your Summer Button – Missed Engagements Alert!',
         template_name: "#{plan}_plan_suspension_notification"
  end
end
