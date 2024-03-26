# frozen_string_literal: true

class ProjectArticle < ApplicationRecord
  include Trackable
  validates :article_hash, presence: true, uniqueness: { scope: [:project_id] }

  enum status_summary: {
         error: 'error',
         skipped: 'skipped',
         wait: 'wait',
         processing: 'processing',
         completed: 'completed',
         static: 'static',
       },
       _prefix: true

  enum status_services: {
         error: 'error',
         skipped: 'skipped',
         wait: 'wait',
         processing: 'processing',
         completed: 'completed',
         static: 'static',
       },
       _prefix: true

  belongs_to :project
  has_many :pages, dependent: :destroy, class_name: 'ProjectPage'
  has_many :statistics, as: :trackable, class_name: 'ProjectStatistic', dependent: :destroy
  has_many :summaries, dependent: :destroy, class_name: 'ProjectArticleSummary'
  has_one :last_summary,
          -> { order id: :desc },
          class_name: 'ProjectArticleSummary',
          foreign_key: :project_article_id

  scope :only_required_columns, -> { select(%w[id project_id title status_summary article_hash]) }

  non_trackable_params(%i[article])

  store :info, accessors: %i[summary services], coder: JsonbSerializer, prefix: true

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

  def log_info(source, info = {})
    Event.create(category: 'log', subcategory: 'info', trackable: self, project_id:, source:, info:)
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
#  info             :jsonb            not null
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
