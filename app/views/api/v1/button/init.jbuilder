# frozen_string_literal: true

json.article do
  json.id @article.article_hash
  json.title @article.title
end
json.settings do
  json.color @current_project.settings_color
  json.size @current_project.settings_font_size
end
