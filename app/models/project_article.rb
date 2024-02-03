# frozen_string_literal: true

class ProjectArticle < ApplicationRecord
  validates :article_hash, presence: true, uniqueness: {
    scope: [:project_id]
  }

  belongs_to :project
  has_many :project_article_urls, dependent: :destroy
  has_many :project_urls, through: :project_article_urls
  has_many :project_article_statistics, dependent: :destroy

  MINIMAL_COLUMNS = %w[id title article_hash].freeze
  SUMMARY_COLUMNS = %w[id project_id title article_hash summary is_summarized].freeze
  scope :summary_columns, -> { select(SUMMARY_COLUMNS) }
  scope :only_required_columns, -> { select(MINIMAL_COLUMNS) }

  def to_param
    encrypted_id
  end

  def encrypted_id
    return nil if id.nil?
    @encrypted_id ||= BasicEncrypting.encode(id)
  end
end

# == Schema Information
#
# Table name: project_articles
#
#  id            :bigint           not null, primary key
#  article       :text             not null
#  article_hash  :string           not null
#  is_accessible :boolean          default(TRUE), not null
#  is_summarized :boolean          default(FALSE), not null
#  summary       :text
#  title         :text             default(""), not null
#  title_hash    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  project_id    :bigint           not null
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
