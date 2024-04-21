# frozen_string_literal: true
class SuspendProjectsJob < ApplicationJob
  queue_as :default
  THRESHOLD = ENV.fetch('FREE_PLAN_CLICKS_THRESHOLD').to_i

  def self.perform(*args)
    new.perform(*args)
  end

  # @param [Integer] project_id
  def perform(project_id = nil)
    if project_id.present?
      suspend_project(project) if ProjectPage.find(project_id).decorate.free_plan_left_clicks&.zero?
      return
    end

    ids =
      ProjectPage
        .joins(:statistics_by_total, :project)
        .where(project: { plan: 'free', status: 'active'})
        .group('project_id')
        .having('SUM(project_statistics_by_totals.clicks) > ?', THRESHOLD)
        .pluck('project_id')

    Project.where(id: ids).find_each { |project| suspend_project(project) }
  end

  private

  # @param [Project] project
  def suspend_project(project)
    project.track!(source: 'SuspendProjectsJob') { project.status_suspended! }

    ProjectMailer.suspension_notification(project.id).deliver_now
  end
end
