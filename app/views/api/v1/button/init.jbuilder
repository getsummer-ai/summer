# frozen_string_literal: true

json.article do
  json.id @article.article_hash
  json.title @article.title
end
json.settings do
  json.color @current_project.settings_color
  json.size @current_project.settings_font_size
  json.filter @current_project.settings_url_filter
  json.container_id @current_project.settings_container_id
end
