# frozen_string_literal: true
json.services @products do |product|
  json.merge! product.decorate.data_for_summary_app
end
