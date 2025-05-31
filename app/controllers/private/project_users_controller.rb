# frozen_string_literal: true
module Private
  class ProjectUsersController < PrivateController
    before_action :find_project
    before_action :find_project_user, only: %i[edit update destroy]

    layout :private_or_turbo_layout
    delegate :h, to: 'ERB::Util'

    def new
      @project_user = @current_project.project_users.build
      @user_form = ProjectUserForm.new(@project_user)
      return if turbo_frame_request?

      anchor = generate_modal_anchor(new_project_project_user_path)
      redirect_to project_settings_path(anchor:)
    end

    def edit
      unless turbo_frame_request?
        anchor = generate_modal_anchor(edit_project_project_user_path(@project, @project_user))
        redirect_to project_settings_path(anchor:)
        return
      end
      @user_form = ProjectUserForm.new(@project_user)
    end

    def create
      @user_form =
        ProjectUserForm.new(
          @current_project.project_users.build,
          params.fetch(:project_user_form, {}).permit(:email, :role),
        )
      return render(:new, status: :unprocessable_entity) unless @user_form.save

      notice = "<b>#{h(@user_form.email)}</b> attached to the project"
      respond_to do |format|
        format.html { redirect_to project_settings_path, notice: }
        format.turbo_stream { flash.now[:notice] = notice }
      end
    end

    def update
      @user_form =
        ProjectUserForm.new(@project_user, params.fetch(:project_user_form, {}).permit(:role))
      return render(:edit, status: :unprocessable_entity) unless @user_form.save

      notice = "<b>#{h(@user_form.email)}</b> is <b>#{h(@user_form.role)}</b> now".html_safe
      respond_to do |format|
        format.html { redirect_to project_settings_path, notice: }
        format.turbo_stream { flash.now[:notice] = notice }
      end
    end

    def destroy
      unless @project_user.destroy
        Rails.logger.error(
          "Error: deleting (#{@project_user.id}) from project #{@project.id} - " +
            @project_user.errors.full_messages.to_s,
        )
        return redirect_to(project_settings_path, alert: 'Error happened while deleting the path')
      end

      notice = "<b>#{h(@project_user.email)}</b> was detached from the project".html_safe
      respond_to do |format|
        format.html { redirect_to project_settings_path, notice: }
        format.turbo_stream { flash.now[:notice] = notice }
      end
    end

    private

    # @return [ProjectUser]
    def find_project_user
      @project_user =
        @current_project.project_users.admins_and_viewers.find(decrypted_or_numeric_param_id)
    end
  end
end
