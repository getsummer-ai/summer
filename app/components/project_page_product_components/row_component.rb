# frozen_string_literal: true

module ProjectPageProductComponents
  class RowComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    # renders_one :form

    def initialize(project_article_product:, edit_path:, update_path:)
      super
      @project_article_product = project_article_product
      @edit_path = edit_path
      @update_path = update_path
    end
  end
end

