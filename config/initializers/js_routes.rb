# frozen_string_literal: true

JsRoutes.setup do |config|
  # Setup your JS module system:
  # ESM, CJS, AMD, UMD or nil
  config.module_type = "ESM"
  # frozen_string_literal: true

  config.file = Rails.root.join('app/frontend/api/routes.js')
end
