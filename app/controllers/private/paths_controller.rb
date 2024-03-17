# frozen_string_literal: true
module Private
  class PathsController < PrivateController
    before_action :find_project
    before_action :find_project_path, only: %i[edit update destroy]
    before_action :paths_count_filter, only: %i[destroy]

    layout :private_or_turbo_layout

    # GET /project/.../paths/new
    def new
      anchor = generate_modal_anchor(new_project_path_path)
      redirect_to project_settings_path(anchor:) unless turbo_frame_request?

      project_path = generate_empty_project_path
      @path_form = ProjectPathForm.new(project_path)
    end

    def edit
      anchor = generate_modal_anchor(edit_project_path_path(@project, @project_path))
      redirect_to project_settings_path(anchor:) unless turbo_frame_request?
      @path_form = ProjectPathForm.new(@project_path)
    end

    def create
      project_path = generate_empty_project_path
      @path_form = ProjectPathForm.new(project_path, value: project_path_params[:value])
      return render(:new, status: :unprocessable_entity) unless @path_form.create

      flash[:notice] = 'Successfully created'
      respond_to do |format|
        format.html { redirect_to project_settings_path }
        format.turbo_stream
      end
    end

    def update
      @path_form = ProjectPathForm.new(@project_path, value: project_path_params[:value])
      new_project_path = @path_form.update
      return render(:edit, status: :unprocessable_entity) unless new_project_path

      respond_to do |format|
        format.html { redirect_to project_settings_path, notice: 'Successfully updated' }
        format.turbo_stream do
          @new_project_path_form = ProjectPathForm.new(new_project_path)
          @new_project_path_statistic = Project::ProjectPath::Statistics.new(
            @project,
            path: new_project_path
          ).result.first
          flash.now[:notice] = 'Successfully updated'
        end
      end
    end

    def destroy
      @path_form = ProjectPathForm.new(@project_path)

      unless @path_form.destroy
        Rails.logger.error("Error: deleting (#{@project_path.path}) from project #{@project.id} - " \
                           + @path_form.errors.full_messages.to_s)
        return redirect_to(project_settings_path, alert: 'Error happened while deleting the path')
      end

      respond_to do |format|
        format.html { redirect_to project_settings_path, notice: "#{@project_path.url} was deleted" }
        format.turbo_stream { flash.now[:notice] = "#{@project_path.url} was deleted" }
      end
    end

    private

    def paths_count_filter
      return unless @project_path.last_one?

      redirect_to project_settings_path, alert: 'You cannot delete the last domain address'
    end

    # Only allow a list of trusted parameters through.
    def project_path_params
      params.fetch(:project_path_form, {}).permit(:value)
    end

    # @return [Project::ProjectPath]
    def generate_empty_project_path
      Project::ProjectPath.new(@project)
    end

    # @return [Project::ProjectPath]
    def find_project_path
      # @type [Project::ProjectPath]
      @project_path = @project.smart_paths.find { |p| p.id == params[:id] }
      return @project_path unless @project_path.nil?

      raise ActiveRecord::RecordNotFound
    end
  end
end
