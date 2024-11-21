# frozen_string_literal: true
module Private
  class PagesController < PrivateController
    include Pagy::Backend
    include ProjectPageFinderConcern
    before_action :find_project
    before_action :set_month, only: %i[index show summary_refresh summary_admin_delete]
    before_action :find_project_page, only: %i[show update summary_refresh summary_admin_delete]
    before_action :find_page_article, only: %i[show summary_refresh summary_admin_delete]
    before_action :check_article_data, only: %i[summary_refresh]

    layout :private_or_turbo_layout

    def index
      @form =
        ProjectPagesQueryForm.new(
          current_project,
          { search: params['search'], order: params['order'] },
          @month,
        )
      @pagy, @pages = pagy(@form.query, items: 12)
      @statistics =
        ProjectStatistic::TotalsViewModel.new(current_project, @month, %i[pages actions])
    end

    def show
      @project_page_decorated = @project_page.decorate
      @project_article_products = @article.project_article_products.includes(:product_minimal_info)

      @statistics =
        ProjectStatistic::ByPageViewModel
          .new(current_project, @month, page_id: @project_page.id)
          .preload_view_click_totals
          .preload_current_month_view_click_totals
    end

    def summary_refresh
      SummarizeArticleJob.perform_now(@article.id)
      @article.reload

      if @article.summary_status_completed? &&
        current_project.products.exists? &&
        (@article.products_status_wait? || @article.related_products.empty?)
        FindProductsInSummaryJob.perform_now(@article.id)
      end

      redirect_to(project_page_path)
    end

    def summary_admin_delete
      return head(:forbidden) unless IS_PLAYGROUND

      @article.update(summary_llm_call_id: nil, summary_status: 'wait')
      flash.now[:alert] = (
        if @article.errors.any?
          @article.errors.full_messages.join(', ')
        else
          'The summary has been deleted'
        end
      )

      show
    end

    def update
      if @project_page.update(params.fetch(:project_page, {}).permit(:is_accessible))
        respond_to do |format|
          format.html do
            redirect_back_or_to project_pages_path, notice: 'URL was successfully updated'
          end
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

    def find_page_article
      @article = ProjectArticle.only_required_columns.find(@project_page.project_article_id)
    end
    
    def check_article_data
      @error_message = nil
      @error_message = 'Can\'t generate a summary for the page.' if @article.summary_status_skipped?
      @error_message = 'Can\'t update the summary. Try again later.' if @article.summary_status_error?
      @error_message = 'Please wait for the completion.' if @article.summary_status_processing?

      if @error_message.nil?
        last_summary_date =
        @article.summary_llm_calls.where(id: @article.summary_llm_call_id).pick(:created_at)
        if last_summary_date.present? && last_summary_date > 1.day.ago
          wait_for = (last_summary_date + 1.day - Time.zone.now) / 1.hour
          @error_message = "Will be available for refresh in #{wait_for.ceil} hour(s)"
        end
      end

      return if @error_message.blank?
      
      flash[:alert] = @error_message
      redirect_to(project_page_path)
    end
  end
end
