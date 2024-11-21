# frozen_string_literal: true

module ProjectPageComponents
  class PreviewSummaryButtonComponent < ViewComponent::Base
    include ViewComponent::UseHelpers
    include ActiveSupport::NumberHelper

    def initialize(current_project:, article:, project_page:, services:)
      super
      @current_project = current_project
      @article = article
      @project_page_decorated = project_page.decorate
      @services = services
    end
  end
end

