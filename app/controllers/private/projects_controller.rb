# frozen_string_literal: true
module Private
  class ProjectsController < PrivateController
    before_action :find_project, except: %i[new create]
    layout :set_new_project_layout, only: %i[new create]

    # GET /projects/new
    def new
      if !turbo_frame_request? && any_project_exist?
        anchor = generate_modal_anchor(new_project_path)
        return redirect_to billing_index_path(anchor:)
      end

      @project = ProjectForm.new(current_user)
      render(:new_modal) if turbo_frame_request?
    end

    def setup
    end

    def update_guidelines
      form = params.fetch(:project, {}).permit(:guidelines)
      res = @project.update(form)

      message = res ? 'Guidelines were successfully updated. ' : 'Guidelines were not updated. '
      message += @project.errors.full_messages.join('. ') if @project.errors.any?
      flash.now[res ? :notice : :alert] = message

      respond_to do |format|
        format.html { redirect_to knowledge_project_path }
        format.turbo_stream
      end
    end

    def update_appearance
      form = params.fetch(:project, {}).permit(
        settings_attributes: [:lang, { appearance_attributes: [:frame_theme, :button_theme] } ]
      )
      @project.update(form)
      # res = @project.update(form)
      # message = res ? 'Appearance setting has changed' : "Appearance settings weren't changed. "
      # message += @project.errors.full_messages.join('. ') if @project.errors.any?
      # flash.now[res ? :notice : :alert] = message

      respond_to do |format|
        format.html { redirect_to setup_project_path }
        format.turbo_stream
      end
    end

    def knowledge
      @products =
        @current_project
          .products
          .skip_retrieving(:icon, :info, :uuid, :created_at, :updated_at, :description, :link)
          .eager_load(:statistics_by_total)
          .order(ProjectStatisticsByTotal.arel_table[:views].desc)
    end

    def create
      @project = ProjectForm.new(current_user, project_params)
      res = @project.create
      return render(:new, status: :unprocessable_entity) unless res

      respond_to do |format|
        format.html { redirect_to(setup_project_path(res), notice: 'Project was successfully created') }
        format.turbo_stream { @redirect_to_url = setup_project_path(res) }
      end
    end

    def destroy
      @project.track!(source: 'Delete Project', author: current_user) do
        @project.update(deleted_at: Time.current.utc, status: :deleted)
      end

      if @project.errors.any?
        error_message =
          "Error happened while deleting project #{@project.id} - " +
            @project.errors.full_messages.to_s
        Rails.logger.error(error_message)
        return redirect_back_or_to(user_app_path, alert: 'Error happened while deleting project')
      end

      redirect_to user_app_path, notice: 'Project was successfully destroyed.'
    end

    private

    def set_new_project_layout
      return 'turbo_rails/frame' if turbo_frame_request?
      return 'login' unless any_project_exist?
      'private'
    end

    def any_project_exist?
      @any_project_exist ||= current_user.projects.exists?
    end

    # Only allow a list of trusted parameters through.
    def project_params
      params.fetch(:project_form, {}).permit(:name, urls: [])
    end
  end
end
