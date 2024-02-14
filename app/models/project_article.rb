# frozen_string_literal: true

class ProjectArticle < ApplicationRecord
  include Trackable
  validates :article_hash, presence: true, uniqueness: { scope: [:project_id] }

  enum status: {
         in_queue: 'in_queue',
         processing: 'processing',
         summarized: 'summarized',
         error: 'error',
         skipped: 'skipped',
       }, _prefix: true
  enum llm: { gpt3: 'gpt3.5', gpt4: 'gpt4' }, _prefix: true

  belongs_to :project
  has_many :project_urls, dependent: :destroy
  has_many :project_article_statistics, dependent: :destroy

  MINIMAL_COLUMNS = %w[id title article_hash].freeze
  SUMMARY_COLUMNS = %w[id project_id title article_hash summary status].freeze
  scope :summary_columns, -> { select(SUMMARY_COLUMNS) }
  scope :only_required_columns, -> { select(MINIMAL_COLUMNS) }

  # custom_untrackable_parmams(%i[heartbeat])

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
#  last_modified_at :datetime
#  last_scraped_at  :datetime
#  llm              :enum
#  service_info     :jsonb
#  status           :enum             default("in_queue"), not null
#  summarized_at    :datetime
#  summary          :text
#  title            :text
#  tokens_in_count  :integer          default(0), not null
#  tokens_out_count :integer          default(0), not null
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
