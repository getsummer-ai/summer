# frozen_string_literal: true

module Setup
  class AppearanceComponent < ViewComponent::Base
    include ViewComponent::UseHelpers

    def initialize(project:)
      super
      @project = project
      @article =
        ProjectArticle
          .only_required_columns
          .where(
            project_id: @project.id,
            summary_status: ProjectArticle.summary_statuses[:completed]
          ).last
    end
  end
end
