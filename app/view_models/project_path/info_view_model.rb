# frozen_string_literal: true
module ProjectPath
  class InfoViewModel
    attr_reader :id, :url, :pages, :views, :clicks
    def initialize(id: nil, url: nil, pages: nil, views: nil, clicks: nil)
      @id = id
      @url = url
      @pages = pages
      @views = views
      @clicks = clicks
    end
  end
end
