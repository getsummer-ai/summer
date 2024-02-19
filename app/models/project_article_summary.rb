# frozen_string_literal: true

class ProjectArticleSummary < ApplicationRecord
  enum llm: { gpt3: 'gpt3.5', gpt4: 'gpt4' }, _prefix: true

  belongs_to :project_article
end

# == Schema Information
#
# Table name: project_article_summaries
#
#  id                 :bigint           not null, primary key
#  info               :jsonb
#  llm                :enum             not null
#  summary            :text
#  tokens_count       :integer          default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  project_article_id :bigint           not null
#
# Indexes
#
#  index_project_article_summaries_on_project_article_id  (project_article_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_article_id => project_articles.id) ON DELETE => cascade ON UPDATE => cascade
#
