# frozen_string_literal: true
module Private
  class ServicesController < PrivateController
    include Pagy::Backend
    before_action :find_project
    before_action :set_service, only: %i[edit update destroy]

    layout :private_or_turbo_layout

    def new
      @project_service = ProjectService.new
      return if turbo_frame_request?
      modal_anchor_to_open = Base64.encode64(new_project_service_path(@current_project))
      # @type [ProjectPageDecorator]
      redirect_to knowledge_project_path(anchor: "m=#{modal_anchor_to_open}")
    end

    def edit
      return if turbo_frame_request?
      modal_anchor_to_open = Base64.encode64(project_service_path(@current_project, @project_service))
      # @type [ProjectPageDecorator]
      redirect_to knowledge_project_path(anchor: "m=#{modal_anchor_to_open}")
    end

    def create
      @project_service = ProjectService.new(service_params.merge(project: @current_project))
      return render(:new, status: :unprocessable_entity) unless @project_service.save

      flash[:notice] = 'Successfully created'
      respond_to do |format|
        format.html { redirect_to knowledge_project_path }
        format.turbo_stream
      end
    end

    def update
      @project_service.update service_params
      return render(:edit, status: :unprocessable_entity) if @project_service.errors.any?

      respond_to do |format|
        format.html { redirect_to project_service_path, notice: 'Successfully updated' }
        format.turbo_stream do
          flash.now[:notice] = 'Successfully updated'
        end
      end
    end

    def destroy
      unless @project_service.destroy
        Rails.logger.error("Error: deleting service (#{@project_service.id}) from project #{@project.id} - " \
                           + @path_form.errors.full_messages.to_s)
        return redirect_to(knowledge_project_path, alert: 'Error happened while deleting the path')
      end

      respond_to do |format|
        format.html { redirect_to @project_service, notice: "#{@project_service.title} was deleted" }
        format.turbo_stream { flash.now[:notice] = "#{@project_service.title} was deleted" }
      end
    end

    private

    def set_service
      @project_service = @current_project.services.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def service_params
      params.fetch(:project_service, {}).permit(:title, :description, :link)
    end
  end
end
