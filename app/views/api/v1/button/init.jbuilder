# frozen_string_literal: true

json.article do
  json.id @combined_id
  json.title @article.title
end
json.settings do
  json.theme @current_project.settings_theme
  json.size @current_project.settings_font_size
  json.paths @current_project.paths
  json.container_id @current_project.settings_container_id
end
