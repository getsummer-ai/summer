# frozen_string_literal: true

class ArticleStatisticService

  # @param [Integer] url_id
  # @param [Integer] article_id
  def initialize(url_id:, article_id:)
    @project_url_id = url_id
    @article_id = article_id
    @time = Time.now.utc
  end

  def view!
    model.increase_views_counter!
  end

  def click!
    model.increase_clicks_counter!
  end

  private

  def model
    @model ||= ProjectArticleStatistic.find_or_create_by(
      project_article_id: @article_id,
      project_url_id: @project_url_id,
      date: @time.to_date,
      hour: @time.hour
    )
  end
end
