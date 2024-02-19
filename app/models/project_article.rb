# frozen_string_literal: true

class ProjectArticle < ApplicationRecord
  include Trackable
  validates :article_hash, presence: true, uniqueness: { scope: [:project_id] }

  enum status_summary: {
         error: 'error',
         skipped: 'skipped',
         wait: 'wait',
         processing: 'processing',
         summarized: 'completed',
         static: 'static',
       },
       _prefix: true

  enum status_services: {
         error: 'error',
         skipped: 'skipped',
         wait: 'wait',
         processing: 'processing',
         summarized: 'completed',
         static: 'static',
       },
       _prefix: true

  belongs_to :project
  has_many :project_urls, dependent: :destroy
  has_many :project_article_statistics, dependent: :destroy
  has_many :project_article_summaries, dependent: :destroy

  MINIMAL_COLUMNS = %w[id title status article_hash].freeze
  SUMMARY_COLUMNS = %w[id project_id title article_hash status_summary].freeze
  scope :summary_columns, -> { select(SUMMARY_COLUMNS) }
  scope :only_required_columns, -> { select(MINIMAL_COLUMNS) }

  non_trackable_params(%i[article])

  def to_param
    encrypted_id
  end

  def encrypted_id
    return nil if id.nil?
    @encrypted_id ||= BasicEncrypting.encode(id)
  end

  def redis_name
    "article-#{article_hash}"
  end
end

# == Schema Information
#
# Table name: project_articles
#
#  id               :bigint           not null, primary key
#  article          :text             not null
#  article_hash     :string           not null
#  image_url        :text
#  info             :jsonb
#  last_modified_at :datetime
#  last_scraped_at  :datetime
#  status_services  :enum             default("wait"), not null
#  status_summary   :enum             default("wait"), not null
#  title            :text
#  tokens_count     :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  project_id       :bigint           not null
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
