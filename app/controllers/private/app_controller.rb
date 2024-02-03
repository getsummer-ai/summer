# frozen_string_literal: true
module Private
  class AppController < PrivateController

    def index
      project = current_user.default_project
      if project.nil? && current_user.projects.first.nil?
        return redirect_to new_project_path
      end
      redirect_to project_path(project || current_user.projects.first)
      # render formats: :html
    end
  end
end
