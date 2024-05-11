# frozen_string_literal: true
module Private
  class AppController < PrivateController
    before_action :find_project

    def index
      return redirect_to(new_project_path) if @project.nil?

      redirect_to @project.pages.exists? ? project_pages_path(@project) : setup_project_path(@project)
    end

    private

    def find_project
      @project = if params[:id].present?
        current_user.projects.available.by_encrypted_id(params[:id])
      else
        current_user.default_project || current_user.projects.available.first
      end
    end
  end
end
