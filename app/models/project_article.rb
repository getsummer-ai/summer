# frozen_string_literal: true

class ProjectArticle < ApplicationRecord
  belongs_to :project

  has_many :project_urls, through: :project_article_urls
  has_many :project_article_statistics, dependent: :destroy
  has_many :project_article_urls, dependent: :destroy

  validates :article_hash, presence: true, uniqueness: {
    scope: [:project_id]
  }

end

# == Schema Information
#
# Table name: project_articles
#
#  id            :bigint           not null, primary key
#  article       :text             not null
#  article_hash  :string           not null
#  is_summarized :boolean          default(FALSE), not null
#  summary       :text
#  title         :text             default(""), not null
#  title_hash    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  project_id    :uuid             not null
#
# Indexes
#
#  index_project_articles_on_project_id                   (project_id)
#  index_project_articles_on_project_id_and_article_hash  (project_id,article_hash) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
