# frozen_string_literal: true
class ProjectSuspensionService
  
  # @param [Project] project
  def initialize(project)
    @project = project
  end

  def actualize_status
    return actualize_free_plan_status if @project.free_plan?
    @project.update!(status: 'active') if @project.paid_plan?
  end

  private

  def actualize_free_plan_status
    @project.update!(status: 'suspended') if @project.decorate.free_plan_left_clicks.zero?
  end
end
