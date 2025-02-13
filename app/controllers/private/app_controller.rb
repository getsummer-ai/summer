# frozen_string_literal: true
module Private
  class AppController < PrivateController
    before_action :try_to_find_project

    def index
      return redirect_to(new_project_path) if @project.nil?

      redirect_to @project.pages.exists? ? project_pages_path(@project) : setup_project_path(@project)
    end

    private

    def try_to_find_project
      return find_project if params[:project_id].present?

      @project = current_user.default_project || current_user.projects.available.first
    end
  end
end
