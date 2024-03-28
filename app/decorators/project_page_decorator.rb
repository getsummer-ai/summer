# frozen_string_literal: true
class ProjectPageDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def summary_symbols
    project_article_id
    ProjectArticleSummary.where(project_article_id:).pick(Arel.sql("CHAR_LENGTH(summary)")) || 0
  end

  def article_symbols
    ProjectArticle.where(id: project_article_id).pick(Arel.sql("CHAR_LENGTH(article)")) || 0
  end
end
