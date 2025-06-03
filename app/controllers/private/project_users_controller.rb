# frozen_string_literal: true
module Private
  class ProjectUsersController < PrivateController
    before_action :find_project
    before_action :find_project_user, only: %i[edit update destroy send_notification_email]

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
      return render(:new, formats: :html, status: :unprocessable_entity) unless @user_form.save

      notice = "<b>#{h(@user_form.email)}</b> was attached to the project".html_safe
      respond_to do |format|
        format.html { redirect_to project_settings_path, notice: }
        format.turbo_stream { flash.now[:notice] = notice }
      end
    end

    def update
      @user_form =
        ProjectUserForm.new(@project_user, params.fetch(:project_user_form, {}).permit(:role))
      return render(:edit, formats: :html, status: :unprocessable_entity) unless @user_form.save

      notice = "<b>#{h(@user_form.email)}</b> is <b>#{h(@user_form.role)}</b> now".html_safe
      respond_to do |format|
        format.html { redirect_to project_settings_path, notice: }
        format.turbo_stream { flash.now[:notice] = notice }
      end
    end

    def destroy
      if @project_user.destroy
        notice = "<b>#{h(@project_user.email)}</b> was detached from the project".html_safe
      else
        errors = @project_user.errors.full_messages.to_s
        Rails.logger.error(
          "Error: deleting (#{@project_user.id}) from project #{@project.id} - #{errors}",
        )
        notice = 'Error happened while deleting the path'
      end

      respond_to do |format|
        format.html { redirect_to project_settings_path, notice: }
        format.turbo_stream { flash.now[:notice] = notice }
      end
    end

    # Checks if invitation email wasn't sent recently
    # and sends it if needed.
    # @return [void]
    def send_notification_email
      if @project_user.invitation_sent_at && @project_user.invitation_sent_at > 1.hour.ago
        alert = 'Invitation email was sent recently. Please try again later.'
      else
        @project_user.send_invitation
        alert = 'Invitation email was sent'
      end

      respond_to do |format|
        format.html { redirect_to project_settings_path, alert: }
        format.turbo_stream { flash.now[:alert] = alert }
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
