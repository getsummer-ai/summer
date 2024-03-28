# frozen_string_literal: true
#
# You only need require libs in two use cases:
# To load files under the lib directory.
# To load gem dependencies that have require: false in the Gemfile .
#
# require 'boilerpipe'
# require 'nokogiri'

class WebScrapperService
  attr_reader :title, :description, :image_url

  USER_AGENT =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ' \
      'AppleWebKit/537.36 (KHTML, like Gecko) ' \
      'Chrome/90.0.4430.212 Safari/537.36'

  # @param [String] url
  # @param [Integer] timeout
  def initialize(url, timeout: 3)
    @url = url
    @timeout = timeout
  end

  # @return [WebScrapperService]
  def scrape
    @response =
      Faraday.get(@url) do |req|
        req.options.timeout = @timeout
        req.headers['User-Agent'] = USER_AGENT
      end

    parse_meta_tags(@response.body)
    self
  end

  # @param [String] body
  def parse_meta_tags(body)
    doc = Nokogiri.HTML(body)
    meta_title_tag = doc.at('meta[property="og:title"]')
    meta_image_tag = doc.at('meta[property="og:image"]')
    meta_og_desc_tag = doc.at('meta[property="og:description"]')
    meta_desc_tag = doc.at('meta[property="description"]')
    @title = meta_title_tag.present? ? meta_title_tag['content'] : nil
    @description = if meta_og_desc_tag.present?
                     meta_og_desc_tag['content']
                   else
                     meta_desc_tag.present? ? meta_desc_tag['content'] : nil
                   end
    @image_url = meta_image_tag.present? ? meta_image_tag['content'] : nil
  end

  def content
    @content ||= Boilerpipe::Extractors::ArticleExtractor.text(@response.body)
  end
end
