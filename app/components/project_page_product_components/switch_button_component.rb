# frozen_string_literal: true

module ProjectPageProductComponents
  class SwitchButtonComponent < ViewComponent::Base

    def initialize(form_url:, project_article_product:)
      super
      @form_url = form_url
      @project_article_product = project_article_product
    end
  end
end

