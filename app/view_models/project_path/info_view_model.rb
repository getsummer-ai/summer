# frozen_string_literal: true
module ProjectPath
  class InfoViewModel
    attr_reader :id, :url, :pages, :views, :clicks

    # @param [String] path
    # @param [String] url
    # @param [Integer] pages
    # @param [Integer] views
    # @param [Integer] clicks
    def initialize(path:, url:, pages:, views:, clicks:)
      @id = path == '' ? 'default' : Base64.encode64(path)
      @url = url
      @pages = pages
      @views = views
      @clicks = clicks
    end

    def to_param
      @id
    end
  end
end
