# frozen_string_literal: true

module ProjectPageProductComponents
  class RowComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    renders_one :form

    def initialize(project_article_product:)
      super
      @project_article_product = project_article_product
    end
  end
end

