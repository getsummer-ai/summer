# frozen_string_literal: true
class CreateFreePlanSubscriptions < ActiveRecord::Migration[7.1]
  def up
    Project.where(subscription_id: nil).find_each do |project|
      Project.transaction do
        subscription = project.subscriptions.create!(
          plan: 'free',
          start_at: project.created_at,
          end_at: '2038-01-01 00:00:00',
          summarize_usage: project.decorate.total_clicks_count,
          summarize_limit: project.free_clicks_threshold,
        )
        project.update!(subscription:) unless project.enterprise_plan?
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
