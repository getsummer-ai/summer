task :before_assets_precompile do
  # res = system({"APPO" => ENV.fetch('APP_API_URL')}, "yarn run build-button-init-app")
  res = system("unset VITE_API_URL && yarn run build-button-init-app")
  raise "Failed to build init-app" if res == false
  res = system("unset VITE_API_URL && yarn run build-button-app")
  raise "Failed to build button-app" if res == false
end

Rake::Task['assets:precompile'].enhance ['before_assets_precompile']
