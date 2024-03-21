# frozen_string_literal: true
module Private
  class ActionsController < PrivateController
    include Pagy::Backend
    before_action :find_project
    before_action :init_update_data, only: %i[update]
    layout :private_or_turbo_layout

    def index
    end

    def update
      if @project.update(params.fetch(:project, {}).permit(:"#{@feature}_enabled"))
        respond_to do |format|
          format.html { redirect_to project_actions_path, notice: 'The feature has been updated' }
          format.turbo_stream { flash.now[:notice] = 'The feature has been updated' }
        end
      else
        @project.reload
        respond_to do |format|
          format.html { redirect_to project_actions_path, notice: "The feature wasn't updated" }
          format.turbo_stream { flash.now[:notice] = "The feature wasn't updated" }
        end
      end
    end

    private

    def init_update_data
      unless %w[feature_suggestion feature_subscription].include?(params[:id].to_s)
        raise ActionController::RoutingError, 'Not Found'
      end
      @feature = params[:id].to_s
      @project.start_tracking(source: "Update #{@feature.titleize}", author: current_user)
    end
  end
end
