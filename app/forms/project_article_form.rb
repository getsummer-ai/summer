# frozen_string_literal: true
class ProjectArticleForm
  include ActiveModel::Validations

  attr_reader :project_page, :dirty_url

  validates :dirty_url, url: true
  validate do
    next if errors.any?
    unless @project.valid_host?(parsed_url&.host)
      errors.add(:base, "The URL must belong to #{@project.domain}")
    end
  end

  # @param [Project] project
  # @param [String] dirty_url
  def initialize(project, dirty_url)
    # @type [Project]
    @project = project
    @dirty_url = dirty_url&.downcase
  end

  # @return [ProjectArticle, nil]
  def find_or_create
    return nil if invalid?
    @project_page = @project.pages.find_by(url_hash:)
    if @project_page.present?
      return @project_page.article
    end
    create_article_and_url
  rescue StandardError => e
    Rails.logger.error e.message
    nil
  end

  # @return [String]
  def url_hash
    @url_hash ||= Hashing.md5(url)
  end

  # @return [String]
  def url
    return @url if defined?(@url)
    prefix = parsed_url.scheme ? "#{parsed_url.scheme}://" : ''
    # host = parsed_url.host.to_s.delete_prefix('www.')
    host = parsed_url.host
    port = [80, 443, nil].include?(parsed_url.port) ? '' : ":#{parsed_url.port}"
    path = parsed_url.path.sub(%r{(/)+$},'')
    @url = [prefix, host, port, path].join
  end

  private

  # @return [Addressable::URI]
  def parsed_url
    @parsed_url ||= Addressable::URI.parse(@dirty_url)
  end

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
    @scraped_article ||= begin
      # The clean URL we store in DB does not have a trailing slash.
      # But if the dirty (incoming) URL ends with a slash -
      # add a slash to the URL we're going to parse to avoid 301 redirects and make a query faster.
      initial_url_has_slash = parsed_url.path.end_with?('/')
      scrape_request_url = initial_url_has_slash ? "#{url}/" : url
      WebScrapperService.new(scrape_request_url).scrape
    end
  end
end
