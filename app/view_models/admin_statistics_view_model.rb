# frozen_string_literal: true

class AdminStatisticsViewModel
  def initialize
    current_time = Time.zone.now
    @article_calculation = {
      in_queue: ProjectArticle.status_in_queue.async_count,
      processing: ProjectArticle.status_processing.async_count,
      summarized: ProjectArticle.status_summarized.async_count,
      tokens_in_count: ProjectArticle.status_summarized.async_sum(:tokens_in_count),
      tokens_out_count: ProjectArticle.status_summarized.async_sum(:tokens_out_count),
      skipped: ProjectArticle.status_skipped.async_count,
      error: ProjectArticle.status_error.async_count,
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
