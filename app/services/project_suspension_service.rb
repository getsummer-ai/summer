# frozen_string_literal: true
class ProjectSuspensionService
  
  # @param [Project] project
  def initialize(project)
    @project = project
  end

  def actualize_status
    if @project.subscription_id.nil?
      Rails.logger.warn("ProjectSuspensionService: project without subscription: #{@project.domain}")
      return
    end

    return suspend_project unless @project.subscription.active?

    activate_project
  end

  def suspend_project(send_out_of_clicks_email: false)
    @project.status_suspended!
    ProjectMailer.out_of_clicks_suspension_notification(@project.id).deliver_now if send_out_of_clicks_email
  end

  def activate_project
    @project.status_active! if @project.status_suspended?
  end
end
