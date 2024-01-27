# frozen_string_literal: true
class ProjectArticleForm
  include ActiveModel::Validations

  attr_accessor :url
  validates :url, url: true

  # @param [Project] project
  # @param [String] url
  def initialize(project, url)
    # @type [Project]
    @project = project
    @url = url.to_s.gsub(/&?utm_.+?(&|$)/, '').chomp('?')
    @hashed_url = Hashing.md5(@url)
  end

  # @return [ProjectArticle, nil]
  def find_or_create
    return nil if invalid?
    project_url = @project.project_urls.find_by(url_hash: @hashed_url)
    return project_url.project_articles.only_required_columns.take if project_url.present?
    create_or_find_article
  rescue StandardError => e
    Rails.logger.error e.message
    nil
  end

  # @return [ProjectArticle, nil]
  def create_or_find_article
    article = nil
    article_hash = Hashing.md5(scraped_article.content)
    ActiveRecord::Base.transaction do
      project_url = @project.project_urls.create!(url: @url, url_hash: @hashed_url)
      article =
        @project
          .project_articles
          .where(article_hash:)
          .first_or_create(
            article: scraped_article.content,
            title: scraped_article.title,
            article_hash:,
            title_hash: Hashing.md5(scraped_article.title),
          )
      article.project_urls << project_url
    end
    article
  end

  # @return [::ArticleScrapperService]
  def scraped_article
    @scraped_article ||= ArticleScrapperService.new(url).scrape
  end
end
