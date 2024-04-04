# frozen_string_literal: true
class ProjectArticleForm
  include ActiveModel::Validations

  attr_accessor :url
  attr_reader :project_page, :url_hash

  validates :url, url: true

  # @param [Project] project
  # @param [String] url
  def initialize(project, url)
    # @type [Project]
    @project = project
    @url = url.to_s.gsub(/&?utm_.+?(&|$)/, '').chomp('?')
    @url_hash = Hashing.md5(@url)
  end

  # @return [ProjectArticle, nil]
  def find_or_create
    return nil if invalid?
    @project_page = @project.pages.find_by(url_hash:)
    if @project_page.present?
      return ProjectArticle.only_required_columns.find_by(id: @project_page.project_article_id)
    end
    create_article_and_url
  rescue StandardError => e
    Rails.logger.error e.message
    nil
  end

  private

  # @return [ProjectArticle, nil]
  def create_article_and_url
    article = nil
    ActiveRecord::Base.transaction do
      article = find_or_create_article(scraped_article)
      @project_page = @project.pages.create!(url:, url_hash:, article:)
    end
    article
  end

  # @param [::WebScrapperService] scraped_article
  # @return [ProjectArticle]
  def find_or_create_article(scraped_article)
    article_hash = Hashing.md5(scraped_article.content)
    tokens = LanguageModelTools.estimate_max_tokens(scraped_article.content)
    @project
      .articles
      .where(article_hash:)
      .first_or_create(
        title: scraped_article.title,
        article_hash:,
        article: scraped_article.content,
        tokens_count: tokens,
        last_scraped_at: Time.now.utc,
        image_url: scraped_article.image_url,
        summary_status: tokens > 500 ? 'wait' : 'skipped',
        products_status: 'wait',
      )
  end

  # @return [::WebScrapperService]
  def scraped_article
    @scraped_article ||= WebScrapperService.new(url).scrape
  end
end
