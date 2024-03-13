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

      @path_form = ProjectPathForm.new(@project)
    end

    def edit
      anchor = generate_modal_anchor(edit_project_path_path(@project, params[:id]))
      redirect_to project_settings_path(anchor:) unless turbo_frame_request?
      @path_form = ProjectPathForm.new(@project, path: @project_path)
    end

    def create
      @path_form = ProjectPathForm.new(@project, value: project_path_params[:value])
      res = @path_form.create
      return redirect_to(project_url(res), notice: 'Project was successfully created') if res

      render :new, status: :unprocessable_entity
    end

    def update
      @path_form = ProjectPathForm.new(@project, path: @project_path, value: project_path_params[:value])
      if @path_form.update
        return redirect_to project_settings_path, notice: 'Domain Address was successfully updated'
      end
      render :edit, status: :unprocessable_entity
    end

    def destroy
      @path_form = ProjectPathForm.new(@project, path: @project_path)

      if @path_form.destroy
        redirect_to project_settings_path, notice: "#{@project_path} was successfully deleted"
      end

      error_message = "Error while deleting path (#{@project_path}) from project #{@project.id} - " \
        + @path_form.errors.full_messages.to_s
      Rails.logger.error(error_message)
      redirect_back_or_to(project_settings_path, alert: 'Error happened while deleting the path')
    end

    private

    def paths_count_filter
      return unless @project.paths.size <= 1

      redirect_to project_settings_path, alert: 'You cannot delete the last domain address'
    end

    # Only allow a list of trusted parameters through.
    def project_path_params
      params.fetch(:project_path, {}).permit(:url)
    end

    # @return [String]
    def find_project_path
      id = params[:id].to_s == 'default' ? "" : Base64.decode(params[:id].to_s)
      @project_path = @project.paths.find { |p| p == id }
      raise ActiveRecord::RecordNotFound if @project_path.nil?
      @project_path
    end
  end
end
