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

  def content
    @content ||= Boilerpipe::Extractors::ArticleExtractor.text(@response.body)
  end

  private

  # @param [String] body
  def parse_meta_tags(body)
    doc = Nokogiri.HTML(body)
    meta_title_tag = find_meta doc, 'og:title'
    meta_image_tag = find_meta doc, 'og:image'
    meta_og_desc_tag = find_meta(doc, 'og:description').presence || doc.at('meta[name="description"]')
    @title = meta_title_tag.present? ? meta_title_tag['content'] : nil
    @description = meta_og_desc_tag.present? ? meta_og_desc_tag['content'] : nil
    @image_url = meta_image_tag.present? ? meta_image_tag['content'] : nil
  end

  # @param [String] name
  # @param [Nokogiri::XML::Element] doc
  # @return [Nokogiri::XML::Element]
  def find_meta(doc, name)
    doc.at("meta[property=\"#{name}\"]").presence || doc.at("meta[name=\"#{name}\"]")
  end
end
