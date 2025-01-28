# frozen_string_literal: true
class ProjectPagesQueryForm
  include ActiveModel::Model

  attr_accessor :search, :order, :show_staging_pages
  validates :order,
            inclusion: {
              in: %w[views_desc views_asc clicks_desc clicks_asc],
            },
            allow_nil: true
  validates :search, length: { maximum: 500 }

  # @param [Project] current_project
  # @param [Hash, ActionController::Parameters] params
  # @param [Date] month
  def initialize(current_project, params, month)
    @current_project = current_project
    @search = params[:search]
    @order = params[:order] || 'views_desc'
    @month = month.beginning_of_month

    @show_staging_pages = params[:show_staging_pages] == 'true'
  end

  def query
    return @current_project.pages.none if invalid?

    pages =
      @current_project
        .pages
        .strict_loading
        .preload(:article)
        .eager_load(:statistics_by_months)
        .joins(Project.sanitize_sql_array(['AND statistics_by_months.month = ?', @month]))

    pages = apply_search(pages) if search.present?

    pages = pages.where(is_primary_domain: true) if @show_staging_pages == false

    apply_order(pages)
  end

  def enabled_filters?
    search.present?
  end

  private

  def apply_search(pages)
    pages.joins(:article).where(
      'project_articles.title ILIKE :search OR project_pages.url ILIKE :search',
      search: "%#{search}%",
    )
  end

  def apply_order(pages)
    case order
    when 'clicks_asc'
      pages.order('statistics_by_months.clicks ASC NULLS LAST')
    when 'clicks_desc'
      pages.order('statistics_by_months.clicks DESC NULLS LAST')
    when 'views_asc'
      pages.order('statistics_by_months.views ASC NULLS LAST')
    else
      pages.order('statistics_by_months.views DESC NULLS LAST')
    end
  end
end
