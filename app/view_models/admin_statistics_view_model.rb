# frozen_string_literal: true

class AdminStatisticsViewModel
  def initialize
    current_time = Time.zone.now
    @article_calculation = {
      wait: ProjectArticle.summary_status_wait.async_count,
      processing: ProjectArticle.summary_status_processing.async_count,
      completed: ProjectArticle.summary_status_completed.async_count,
      tokens_count: ProjectArticle.summary_status_completed.async_sum(:out_tokens_count),
      # tokens_out_count: ProjectArticle.summary_status_completed.async_sum(:tokens_count),
      skipped: ProjectArticle.summary_status_skipped.async_count,
      error: ProjectArticle.summary_status_error.async_count,
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
