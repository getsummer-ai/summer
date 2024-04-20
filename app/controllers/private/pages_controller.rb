# frozen_string_literal: true
module Private
  class PagesController < PrivateController
    include Pagy::Backend
    before_action :find_project
    before_action :set_url, only: %i[show update]

    layout :private_or_turbo_layout

    def index
      @statistics = ProjectStatisticsViewModel.new(@current_project, [:views, :actions])
      @pagy, @pages = pagy(
        @current_project
          .pages
          .preload(:article_only_title)
          .eager_load(:statistics_by_total)
          .order(ProjectStatisticsByTotal.arel_table[:views].desc),
        items: 30,
        link_extra: 'data-turbo-frame="pages"'
      )
    end

    def show
      @project_page_decorated = @project_page.decorate

      return if turbo_frame_request?
      modal_anchor_to_open = Base64.encode64(project_page_path(@current_project, @project_page))
      # @type [ProjectPageDecorator]
      redirect_to project_pages_path(anchor: "m=#{modal_anchor_to_open}")
    end

    def update
      if @project_page.update(url_params)
        respond_to do |format|
          format.html { redirect_back_or_to project_pages_path, notice: 'URL was successfully updated' }
          format.turbo_stream { flash.now[:notice] = 'URL was successfully updated' }
        end
      else
        redirect_back_or_to project_pages_path, error: "URL wasn't updated."
      end
    end

    private

    def set_url
      pages_query = @current_project.pages
      condition =  params[:id].to_s.length == 32 ? { url_hash: params[:id] } : { id: params[:id] }
      @project_page = pages_query.find_by!(condition)
    end

    # Only allow a list of trusted parameters through.
    def url_params
      params.fetch(:project_page, {}).permit(:is_accessible)
    end
  end
end
