# frozen_string_literal: true
module Private
  class ProjectsController < PrivateController
    before_action :set_project, only: %i[show edit update destroy]

    # GET /projects or /projects.json
    def index
      @projects = current_user.projects.all
    end

    # GET /projects/1 or /projects/1.json
    def show
    end

    # GET /projects/new
    def new
      @project = Project.new
    end

    # GET /projects/1/edit
    def edit
    end

    # POST /projects or /projects.json
    def create
      @project = Project.new(project_params.merge(user_id: current_user.id))

      respond_to do |format|
        if @project.save
          format.html do
            redirect_to project_url(@project), notice: 'Project was successfully created.'
          end
          format.json { render :show, status: :created, location: @project }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /projects/1 or /projects/1.json
    def update
      respond_to do |format|
        if @project.update(project_params)
          format.html do
            redirect_to project_url(@project), notice: 'Project was successfully updated.'
          end
          format.json { render :show, status: :ok, location: @project }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /projects/1 or /projects/1.json
    def destroy
      @project.destroy!

      respond_to do |format|
        format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = current_user.projects.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.fetch(:project, {}).permit(:name, :domain, :settings_container_id, :settings_url_filter)
    end
  end
end
