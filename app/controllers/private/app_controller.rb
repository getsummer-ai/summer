# frozen_string_literal: true
module Private
  class AppController < PrivateController

    def index
      project = current_user.default_project
      return redirect_to project_path(project) if project.present?

      project = current_user.projects.available.first
      return redirect_to project_path(project) if project.present?

      redirect_to(new_project_path)
    end
  end
end
