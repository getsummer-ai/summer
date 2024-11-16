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
    ProjectArticle
      .joins(:summary_llm_call)
      .where(id: project_article_id)
      .pick(Arel.sql('CHAR_LENGTH(output)')) || 0
  end

  def article_symbols
    return article.article&.length || 0 if association(:article).loaded?
    ProjectArticle.where(id: project_article_id).pick(Arel.sql('CHAR_LENGTH(article)')) || 0
  end

  # @return [String]
  def summary_html
    MarkdownLib.render(summary_md)
  end

  def summary_md
    article_summary_info[0] || ''
  end

  # @return [String]
  def summary_created_at
    article_summary_info[1]
  end

  def article_summary_info
    @article_summary_info ||= ProjectArticle
      .joins(:summary_llm_call)
      .where(id: project_article_id)
      .pick(:output, 'project_llm_calls.created_at') || ['', nil]
  end
end
