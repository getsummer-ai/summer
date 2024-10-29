# frozen_string_literal: true
module Private
  class PagesController < PrivateController
    include Pagy::Backend
    include ProjectPageFinderConcern
    before_action :find_project
    before_action :set_month, only: %i[index]
    before_action :find_project_page, only: %i[show update summary summary_refresh summary_admin_delete]
    before_action :redirect_to_summary_modal_if_not_turbo, only: %i[summary summary_refresh summary_admin_delete]

    layout :private_or_turbo_layout

    def index
      @form = ProjectPagesQueryForm.new(current_project, query_pages_form_params, @month)
      @pagy, @pages = pagy(@form.query, items: 12)
      @statistics = ProjectStatistic::TotalsViewModel.new(current_project, @month, %i[pages actions])
    end

    def show
      @project_page_decorated = @project_page.decorate

      return if turbo_frame_request?
      # modal_anchor_to_open = Base64.encode64(project_page_path(@current_project, @project_page))
      # @type [ProjectPageDecorator]
      # redirect_to project_pages_path(anchor: "m=#{modal_anchor_to_open}")
      render 'show_new'
    end

    def summary
      @go_back_path = project_page_path(@current_project, @project_page)
      @project_page_decorated = @project_page.decorate
    end

    def summary_refresh
      @article = ProjectArticle.only_required_columns.find_by(id: @project_page.project_article_id)
      @error_message = 'Can\'t update the summary. Try again later.'
      @error_message = 'Please wait for the summary completion.' if @article.summary_status_processing?
      return unless @article.summary_status_completed?

      last_summary_date = @article.summary_llm_calls.where(id: @article.summary_llm_call_id).pick(:created_at)
      if last_summary_date > 1.day.ago
        wait_for = (last_summary_date + 1.day - Time.zone.now) / 1.hour
        @error_message = "Will be available for refresh in #{wait_for.ceil} hour(s)"
        return
      end

      SummarizeArticleJob.perform_now(@article.id)
      @error_message = nil
    end

    def summary_admin_delete
      return head(:forbidden) unless IS_PLAYGROUND

      @article = ProjectArticle.only_required_columns.find_by(id: @project_page.project_article_id)
      @article.update(summary_llm_call_id: nil, summary_status: 'wait')
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

    def set_month
      @month = Date.strptime(params[:month], '%Y-%m-%d') if params[:month].present?
      return if @month.present?

      @month = current_project.statistics_by_month.maximum(:month)&.beginning_of_month
      @month = Time.zone.today.beginning_of_month if @month.nil?
    rescue ArgumentError
      raise ActionController::BadRequest, 'The month is incorrect'
    end

    def query_pages_form_params
      { search: params['search'], order: params['order'] }
    end

    def redirect_to_summary_modal_if_not_turbo
      return if turbo_frame_request?
      modal_anchor_to_open = Base64.encode64(summary_project_page_path(@current_project, @project_page))
      redirect_to project_pages_path(anchor: "m=#{modal_anchor_to_open}")
    end

    # Only allow a list of trusted parameters through.
    def url_params
      params.fetch(:project_page, {}).permit(:is_accessible)
    end
  end
end
