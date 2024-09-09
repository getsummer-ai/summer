# frozen_string_literal: true

# @!attribute info
#  @return [ProjectArticle::Info]
class ProjectArticle < ApplicationRecord
  include StoreModel::NestedAttributes
  include Trackable

  non_trackable_params(%i[article])

  attribute :info, ProjectArticle::Info.to_type
  accepts_nested_attributes_for :info, allow_destroy: false

  def info_attributes=(attributes)
    info.assign_attributes(attributes)
  end

  enum :summary_status, {
         error: 'error',
         skipped: 'skipped',
         wait: 'wait',
         processing: 'processing',
         completed: 'completed',
       }, prefix: true

  enum :products_status, {
         error: 'error',
         skipped: 'skipped',
         wait: 'wait',
         processing: 'processing',
         completed: 'completed',
       }, prefix: true

  belongs_to :project
  has_many :pages, dependent: :destroy, class_name: 'ProjectPage'
  has_many :statistics, as: :trackable, class_name: 'ProjectStatistic', dependent: :destroy
  has_many :summary_llm_calls,
           -> { where(feature: 'summary') },
           as: :initializer,
           class_name: 'ProjectLlmCall',
           dependent: :destroy,
           inverse_of: :initializer

  has_many :products_llm_calls,
           -> { where(feature: 'products') },
           as: :initializer,
           class_name: 'ProjectLlmCall',
           dependent: :destroy,
           inverse_of: :initializer

  has_many :project_article_products, dependent: :destroy
  has_many :related_products,
           through: :project_article_products,
           class_name: 'ProjectProduct',
           source: :product

  belongs_to :summary_llm_call,
             -> { select(:output) },
             class_name: 'ProjectLlmCall',
             optional: true
  belongs_to :products_llm_call,
             -> { select(:output) },
             class_name: 'ProjectLlmCall',
             optional: true

  validates :article_hash, presence: true, uniqueness: { scope: [:project_id] }
  validates :info, store_model: { merge_errors: true }

  scope :only_required_columns,
        -> do
          select(
            %w[
              id
              project_id
              title
              info
              summary_status
              products_status
              summary_llm_call_id
              products_llm_call_id
              article_hash
            ],
          )
        end

  def to_param
    encrypted_id
  end

  def encrypted_id
    return nil if id.nil?
    @encrypted_id ||= BasicEncrypting.encode(id)
  end

  def redis_summary_name
    "pa-#{article_hash}-summary"
  end

  def redis_products_name
    "pa-#{article_hash}-products"
  end

  def log_info(source, info = {})
    Event.create(category: 'log', subcategory: 'info', trackable: self, project_id:, source:, info:)
  end
end

# == Schema Information
#
# Table name: project_articles
#
#  id                   :bigint           not null, primary key
#  article              :text             not null
#  article_hash         :string           not null
#  image_url            :text
#  info                 :jsonb            not null
#  last_modified_at     :datetime
#  last_scraped_at      :datetime
#  products_status      :enum             default("wait"), not null
#  summary_status       :enum             default("wait"), not null
#  title                :text
#  tokens_count         :integer          default(0), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  products_llm_call_id :bigint
#  project_id           :bigint           not null
#  summary_llm_call_id  :bigint
#
# Indexes
#
#  index_project_articles_on_products_llm_call_id         (products_llm_call_id)
#  index_project_articles_on_project_id                   (project_id)
#  index_project_articles_on_project_id_and_article_hash  (project_id,article_hash) UNIQUE
#  index_project_articles_on_summary_llm_call_id          (summary_llm_call_id)
#
# Foreign Keys
#
#  fk_rails_...  (products_llm_call_id => project_llm_calls.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (summary_llm_call_id => project_llm_calls.id)
#
