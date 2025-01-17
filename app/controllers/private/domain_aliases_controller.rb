# frozen_string_literal: true
module Private
  class DomainAliasesController < PrivateController
    before_action :find_project

    layout :private_or_turbo_layout

    # GET /project/.../paths/new

    def edit
      unless turbo_frame_request?
        redirect_to project_settings_path(anchor: generate_modal_anchor(project_domain_alias_path))
      end
      @domain_alias_form = ProjectDomainAliasForm.new(current_project)
    end

    def update
      @domain_alias_form = ProjectDomainAliasForm.new(current_project, project_domain_alias_params)
      return render(:edit, status: :unprocessable_entity) unless @domain_alias_form.update

      flash.now[:notice] = 'Successfully updated'
      respond_to do |format|
        format.html { redirect_to project_settings_path }
        format.turbo_stream
      end
    end

    def destroy
      current_project.start_tracking(source: 'Destroy Domain Alias', author: current_user)
      domain_alias = current_project.domain_alias
      unless current_project.update(domain_alias: nil)
        return(
          redirect_to(
            project_settings_path,
            alert: 'Error happened while deleting the staing domain',
          )
        )
      end

      respond_to do |format|
        format.html do
          redirect_to project_settings_path, notice: "#{domain_alias} was detached"
        end
        format.turbo_stream { flash.now[:notice] = "#{domain_alias} was detached" }
      end
    end

    private

    # Only allow a list of trusted parameters through.
    def project_domain_alias_params
      params.fetch(:project_domain_alias_form, {}).permit(:url)
    end
  end
end
