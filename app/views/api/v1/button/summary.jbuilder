# frozen_string_literal: true

json.article do
  json.id @article.article_hash
  json.title @article.title
  json.summary @html_summary
end
