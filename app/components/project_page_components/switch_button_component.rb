# frozen_string_literal: true

module ProjectPageComponents
  class SwitchButtonComponent < ViewComponent::Base
    # include Rails.application.routes.url_helpers

    def initialize(project:, page:, is_checkbox: )
      super
      @project = project
      @page = page
      @is_checkbox = is_checkbox
    end

    def custom_dom_id
      prefix = @is_checkbox ? :switch_checkbox : :switch_button
      dom_id(@page, prefix)
    end
  end
end

