# frozen_string_literal: true
module Private
  class ProjectsController < PrivateController
    before_action :find_project, except: %i[new create]
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
      layout_name = current_user.projects.count.positive? ? 'private' : 'login'
      render :new, status: :unprocessable_entity, layout: layout_name
    end

    def setup
    end

    def knowledge
    end

    def settings
    end

    # GET /projects/1/edit
    def edit
    end

    # POST /projects or /projects.json
    def create
      @project = ProjectForm.new(current_user, project_params)
      res = @project.create
      if res
        return redirect_to project_url(res), notice: 'Project was successfully created.'
      end
      layout_name = current_user.projects.count.positive? ? 'private' : 'login'
      render :new, status: :unprocessable_entity, layout: layout_name
    end

    # PATCH/PUT /projects/1 or /projects/1.json
    def update
      @project.start_tracking(source: 'Update Project Form', author: current_user)
      if @project.update(project_params)
        return redirect_to project_url(@project), notice: 'Project was successfully updated.'
      end
      render :edit, status: :unprocessable_entity
    end

    # DELETE /projects/1 or /projects/1.json
    def destroy
      @project.destroy!
      redirect_to projects_url, notice: 'Project was successfully destroyed.'
    end

    private

    # Only allow a list of trusted parameters through.
    def project_params
      params.fetch(:project_form, {}).permit(:name, :urls)
    end
  end
end
