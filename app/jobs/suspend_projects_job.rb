# frozen_string_literal: true
#
# The job that manages the suspension and
# activation of projects based on their subscription status
# and usage limits. It suspends projects that have exceeded
# their usage limits or whose subscriptions have expired
# and activates projects that are within their usage limits
# and have valid subscriptions
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
      return suspend_project(project) if project.subscription_id.nil?
      return suspend_project(project) unless project.subscription.active?
    end

    check_projects_on_suspension
    check_projects_on_activation
  end

  private

  # Suspend projects that have exceeded the limit of clicks or have expired.
  def check_projects_on_suspension
    Project.eager_load(:subscription)
      .where(status: 'active')
      .where('summarize_usage >= summarize_limit OR end_at <= :time OR cancel_at <= :time', time: Time.now.utc)
      .where.not(subscription_id: nil)
      .find_each { |project| suspend_project(project) }
  end

  def check_projects_on_activation
    Project.joins(:subscription)
      .where(status: 'suspended')
      .where(
        "summarize_usage < summarize_limit AND end_at > :time AND (cancel_at IS NULL OR cancel_at > :time)",
        time: Time.now.utc
      ).find_each { |project| activate_project(project) }
  end

  # @param [Project] project
  def suspend_project(project)
    project.start_tracking(source: "SuspendProjectsJob - Suspension - #{project.plan}")

    ProjectSuspensionService.new(project).suspend_project(
      send_out_of_clicks_email: !project.subscription.clicks?
    )
  end

  # @param [Project] project
  def activate_project(project)
    project.start_tracking(source: "SuspendProjectsJob - Activation - #{project.plan}")
    ProjectSuspensionService.new(project).activate_project
  end
end
