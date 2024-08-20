# frozen_string_literal: true

json.path @app_path
json.settings do
  json.lang current_project.settings.lang
  json.appearance current_project.settings.appearance
  # json.size @current_project.settings_font_size
  json.paths current_project.paths
  json.features do
    json.suggestion current_project.settings.feature_suggestion.enabled
    json.subscription current_project.settings.feature_subscription.enabled
  end
end
