# frozen_string_literal: true
#
# You only need require libs in two use cases:
# To load files under the lib directory.
# To load gem dependencies that have require: false in the Gemfile .
#
# require 'boilerpipe'
# require 'nokogiri'

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
      Faraday.get(@url) do |req|
        req.options.timeout = 3
        req.headers['User-Agent'] = USER_AGENT
      end
    @content = Boilerpipe::Extractors::ArticleExtractor.text(response.body)
    # puts @content
    doc = Nokogiri.HTML(response.body)
    meta_title_tag = doc.at('meta[property="og:title"]')
    meta_image_tag = doc.at('meta[property="og:image"]')
    @title = meta_title_tag.present? ? meta_title_tag['content'] : nil
    @image_url = meta_image_tag.present? ? meta_image_tag['content'] : nil
    # @image_url = doc.at('meta[property="og:image"]')&['content']
    self
  end
end
