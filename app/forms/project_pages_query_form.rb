# frozen_string_literal: true
class ProjectPagesQueryForm
  include ActiveModel::Model

  attr_accessor :search, :order
  validates :order,
            inclusion: {
              in: %w[views_desc views_asc actions_desc actions_asc],
            },
            allow_nil: true
  validates :search, length: { maximum: 500 }

  # @param [Project] current_project
  # @param [Hash, ActionController::Parameters] params
  def initialize(current_project, params)
    @current_project = current_project
    @search = params[:search]
    @order = params[:order]
  end

  def query
    return @current_project.pages.none if invalid?

    pages = @current_project.pages.preload(:article_only_title).eager_load(:statistics_by_total)

    pages = apply_search(pages) if search.present?
    apply_order(pages)
  end

  def enabled_filters?
    search.present?
  end

  private

  def apply_search(pages)
    pages.joins(:article_only_title).where(
      'project_articles.title ILIKE :search OR project_pages.url ILIKE :search',
      search: "%#{search}%",
    )
  end

  def apply_order(pages)
    case order
    when 'views_asc'
      pages.order(ProjectStatisticsByTotal.arel_table[:views].asc.nulls_last)
    when 'actions_desc'
      pages.order(ProjectStatisticsByTotal.arel_table[:actions].desc.nulls_last)
    when 'actions_asc'
      pages.order(ProjectStatisticsByTotal.arel_table[:actions].asc.nulls_last)
    else
      pages.order(ProjectStatisticsByTotal.arel_table[:views].desc.nulls_last)
    end
  end
end
