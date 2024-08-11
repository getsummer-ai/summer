# frozen_string_literal: true
#
# A job that checks the number of clicks for each project and suspends it if the threshold is exceeded.
# Free plan projects are suspended if the total number of clicks exceeds the threshold.
# Light and Pro plan projects are suspended if the number of clicks in the current month exceeds the threshold.
#
class SuspendProjectsJob < ApplicationJob
  queue_as :default

  def self.perform(*args)
    new.perform(*args)
  end

  # @param [Integer] project_id
  def perform(project_id = nil)
    if project_id.present?
      project = Project.find(project_id)
      return suspend_project(project) if project.decorate.plan_left_clicks&.zero?
    end

    check_free_projects
    check_plan_projects(plan: 'light', threshold: Project::LIGHT_PLAN_THRESHOLD)
    check_plan_projects(plan: 'pro', threshold: Project::PRO_PLAN_THRESHOLD)
  end

  private

  def check_free_projects
    ids =
      ProjectPage
        .joins(:statistics_by_total, :project)
        .where(project: { plan: 'free', status: 'active' })
        .group('project_id', '"project"."free_clicks_threshold"')
        .having('SUM(project_statistics_by_totals.clicks) > "project"."free_clicks_threshold"')
        .pluck('project_id')

    Project.where(id: ids).find_each { |project| suspend_project(project) }
  end

  def check_plan_projects(plan:, threshold:)
    ids_query = ProjectStatistic.by_pages.current_month.joins(:project).group('project_id')

    ids_to_suspend =
      ids_query
        .having('SUM(clicks) >= ?', threshold)
        .where(project: { plan:, status: 'active' })
        .pluck('project_id')

    ids_to_activate =
      ids_query
        .having('SUM(clicks) < ?', threshold)
        .where(project: { plan:, status: 'suspended' })
        .pluck('project_id')

    Project.where(id: ids_to_suspend).find_each { |project| suspend_project(project) }
    Project.where(id: ids_to_activate).find_each { |project| activate_project(project) }

    # The following code is an alternative way to implement the same logic.
    # Sql query way is more efficient than the following code.
    #
    # ids_info =
    #   ProjectStatistic
    #     .by_pages
    #     .current_month
    #     .joins(:project)
    #     .where(project: { plan: , status: %w[active suspended] })
    #     .pluck('project_id', 'SUM(project_statistics_by_totals.clicks)')
    # ids_info_hash = ids_info.to_h
    # Project.where(id: ids_info_hash.keys).find_each do |project|
    #   ids_info_hash[project.id] >= threshold ? suspend_project(project) : activate_project(project)
    # end
  end

  # @param [Project] project
  def suspend_project(project)
    project.start_tracking(source: "SuspendProjectsJob - Suspension - #{project.plan}")
    ProjectSuspensionService.new(project).suspend_project(send_email: true)
  end

  # @param [Project] project
  def activate_project(project)
    project.start_tracking(source: "SuspendProjectsJob - Activation - #{project.plan}")
    ProjectSuspensionService.new(project).activate_project
  end
end
