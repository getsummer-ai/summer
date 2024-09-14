# frozen_string_literal: true
class ProjectSuspensionService
  
  # @param [Project] project
  def initialize(project)
    @project = project
  end

  def actualize_status
    return suspend_project if @project.decorate.plan_left_clicks.zero?

    activate_project if @project.status_suspended?
  end

  def suspend_project(send_out_of_clicks_email: false)
    @project.status_suspended!
    ProjectMailer.out_of_clicks_suspension_notification(@project.id).deliver_now if send_out_of_clicks_email
  end

  def activate_project
    @project.status_active! if @project.status_suspended?
  end
end
