# frozen_string_literal: true
module Private
  class ProjectsController < PrivateController
    before_action :find_project, except: %i[new create]
    layout :set_new_project_layout, only: %i[new create]

    # GET /projects or /projects.json
    # def index
    #   @projects = current_user.projects.all
    # end

    # GET /projects/1 or /projects/1.json
    def show
    end

    # GET /projects/new
    def new
      @project = ProjectForm.new(current_user)
      render(:new_modal) if turbo_frame_request?
    end

    def setup
    end

    def knowledge
    end

    # GET /projects/1/edit
    def edit
    end

    def create
      @project = ProjectForm.new(current_user, project_params)
      res = @project.create
      return redirect_to(project_url(res), notice: 'Project was successfully created') if res

      render :new, status: :unprocessable_entity
    end

    def update
      @project.start_tracking(source: 'Update Project Form', author: current_user)
      if @project.update(project_params)
        return redirect_to project_url(@project), notice: 'Project was successfully updated.'
      end
      render :edit, status: :unprocessable_entity
    end

    def destroy
      @project.track!(source: 'Delete Project', author: current_user) do
        @project.update(deleted_at: Time.current.utc, status: :deleted)
      end

      if @project.errors.any?
        error_message = "Error happened while deleting project #{@project.id} - " + @project.errors.full_messages.to_s
        Rails.logger.error(error_message)
        return redirect_back_or_to(user_app_path, alert: 'Error happened while deleting project')
      end

      redirect_to user_app_path, notice: 'Project was successfully destroyed.'
    end

    private

    def set_new_project_layout
      return 'turbo_rails/frame' if turbo_frame_request?
      return 'login' unless current_user.projects.exists?
      'private'
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.fetch(:project_form, {}).permit(:name, urls: [])
    end
  end
end
