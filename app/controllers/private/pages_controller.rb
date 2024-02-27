# frozen_string_literal: true
module Private
  class PagesController < PrivateController
    before_action :find_project
    before_action :set_url, only: %i[update]

    layout :custom_layout

    def custom_layout
      return 'turbo_rails/frame' if turbo_frame_request?
      'private'
    end

    def index
      @urls = @current_project.project_urls
              .preload(:article_only_title)
              .eager_load(:statistics_by_total)
              .order(ProjectUrlStatisticsByTotal.arel_table[:views].asc)
    end

    def update
      if @current_url.update(url_params)
        respond_to do |format|
          format.html { redirect_to project_pages_path, notice: 'URL was successfully updated' }
          format.turbo_stream { flash.now[:notice] = 'URL was successfully updated' }
        end
      else
        redirect_to project_pages_path, error: "URL wasn't updated."
      end
    end

    private

    def set_url
      @current_url = @current_project.project_urls.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def url_params
      params.fetch(:project_url, {}).permit(:is_accessible)
    end
  end
end
