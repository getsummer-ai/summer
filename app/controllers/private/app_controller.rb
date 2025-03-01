# frozen_string_literal: true
module Private
  class AppController < PrivateController
    before_action :try_to_find_project
    before_action :try_to_find_framer_auth_session_id

    def index
      return redirect_to(success_plugins_framer_path(@framer_session_id)) if @framer_session_id.present?
      return redirect_to(new_project_path) if @project.nil?
      return redirect_to setup_project_path(@project) unless @project.pages.exists?

      redirect_to project_pages_path(@project)
    end

    private

    def try_to_find_framer_auth_session_id
      @framer_session_id = nil
      if params[:framer_session_id].present? && session[:framer_session_id].present?
        @framer_session_id = params[:framer_session_id]
      end
    end

    def try_to_find_project
      return find_project if params[:project_id].present?

      @project = current_user.default_project || current_user.projects.available.first
    end
  end
end
