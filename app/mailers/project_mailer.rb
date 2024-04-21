# frozen_string_literal: true
#
# Mailer that is responsible for sending emails related to project activities.
#
class ProjectMailer < MjmlMailer
  def suspension_notification(project_id)
    @project = Project.find(project_id).decorate
    mail to: @project.user.email, subject:  "Project #{@project.name} suspended"
  end
end
