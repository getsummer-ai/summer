# frozen_string_literal: true
require 'redcarpet'
module MarkdownLib
  RENDER_OPTIONS = {
    filter_html: true,
    hard_wrap: true,
    link_attributes: { rel: 'nofollow', target: "_blank" },
    space_after_headers: true,
    fenced_code_blocks: true
  }.freeze

  MARKDOWN_EXTENSIONS = {
    autolink: true,
    superscript: true,
    disable_indented_code_blocks: true
  }.freeze

  # @param [String] str
  def self.render(str)
    renderer = ::Redcarpet::Render::HTML.new(RENDER_OPTIONS)
    @markdown = ::Redcarpet::Markdown.new(renderer, MARKDOWN_EXTENSIONS)
    @markdown.render(str || '')
  end
end
