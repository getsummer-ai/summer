# frozen_string_literal: true

class AdminStatisticsViewModel
  def initialize
    current_time = Time.zone.now
    @article_calculation = {
      wait: ProjectArticle.status_summary_wait.async_count,
      processing: ProjectArticle.status_summary_processing.async_count,
      completed: ProjectArticle.status_summary_completed.async_count,
      tokens_count: ProjectArticle.status_summary_completed.async_sum(:tokens_count),
      # tokens_out_count: ProjectArticle.status_summary_completed.async_sum(:tokens_count),
      skipped: ProjectArticle.status_summary_skipped.async_count,
      error: ProjectArticle.status_summary_error.async_count,
    }

    @users_today = User.where(created_at: current_time.all_day).async_count
    @users = User.async_count
    @projects = Project.async_count
  end

  def articles
    @articles ||= @article_calculation.transform_values(&:value)
  end

  def projects
    @projects.value
  end

  def users_today
    @users_today.value
  end

  def users
    @users.value
  end
end
