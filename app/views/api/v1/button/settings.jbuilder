# frozen_string_literal: true

json.path @app_path
json.settings do
  json.theme @current_project.settings_theme
  # json.size @current_project.settings_font_size
  json.paths @current_project.paths
  json.features do
    json.suggestion @current_project.feature_suggestion_enabled
    json.subscription @current_project.feature_subscription_enabled
  end
end
