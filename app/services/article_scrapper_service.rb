# frozen_string_literal: true
class ArticleScrapperService
  attr_reader :content, :title, :image_url

  USER_AGENT =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' \
      'AppleWebKit/537.36 (KHTML, like Gecko) ' \
      'Chrome/90.0.4430.212 Safari/537.36'

  # @param [String] url
  def initialize(url)
    @url = url
  end

  # @return [ArticleScrapperService]
  def scrape
    response =
      Faraday.get(@url, { 'User-Agent': USER_AGENT }) do |req|
        req.options.timeout = 5
        req.headers['User-Agent'] = USER_AGENT
      end
    @content = Boilerpipe::Extractors::ArticleExtractor.text(response.body)
    puts @content
    doc = Nokogiri.HTML(response.body)
    meta_tag = doc.at('meta[property="og:title"]')
    @title = meta_tag.present? ? meta_tag['content'] : @content.truncate_words(6)
    # @image_url = doc.at('meta[property="og:image"]')&['content']
    self
  end
end
