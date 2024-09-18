# frozen_string_literal: true

# @!attribute settings
#  @return [ProjectSettings]
# @!attribute stripe
#  @return [ProjectStripeDetails]
class Project < ApplicationRecord
  include StoreModel::NestedAttributes
  include Trackable
  include EncryptedKey
  include PassiveColumns

  LIGHT_PLAN_THRESHOLD = 5_000
  PRO_PLAN_THRESHOLD = 25_000

  ALREADY_TAKEN_ERROR = 'is already taken'

  enum :plan, { free: 'free', light: 'light', pro: 'pro', enterprise: 'enterprise' }, suffix: true
  enum :status, { active: 'active', suspended: 'suspended', deleted: 'deleted' }, prefix: true
  enum :default_llm, {
         gpt_35_turbo: 'gpt-3.5-turbo',
         gpt_4o: 'gpt-4o',
         gpt_4o_mini: 'gpt-4o-mini',
       }, prefix: true

  attribute :settings, Project::ProjectSettings.to_type
  attribute :stripe, Project::ProjectStripeDetails.to_type

  # Fix for StoreModel gem
  # TODO: remove this check after new StoreModel version release
  if (ActiveRecord::Base.connection_pool.with_connection(&:active?) rescue false) &&
    ActiveRecord::Base.connection.table_exists?('projects')
    accepts_nested_attributes_for :settings
    accepts_nested_attributes_for :stripe
  end

  passive_columns :guidelines, :stripe

  def settings_attributes=(attributes)
    settings.assign_attributes(attributes)
  end

  def stripe_attributes=(attributes)
    stripe.assign_attributes(attributes)
  end

  track_changes_formatter_for :settings do |old_value, new_value|
    original, changed = new_value.as_json, old_value.as_json
    [HashDiffer.new(original, changed).deep_diff, HashDiffer.new(changed, original).deep_diff]
  end

  alias project_id id

  belongs_to :user
  belongs_to :subscription, class_name: 'ProjectSubscription', optional: true
  has_many :subscriptions, dependent: :destroy, class_name: 'ProjectSubscription'
  has_many :pages, dependent: :destroy, class_name: 'ProjectPage'
  has_many :articles, dependent: :destroy, class_name: 'ProjectArticle'
  has_many :products, dependent: :destroy, class_name: 'ProjectProduct'
  has_many :statistics, class_name: 'ProjectStatistic', dependent: :destroy
  has_many :all_events, class_name: 'Event'
  has_many :user_emails, class_name: 'ProjectUserEmail', dependent: :destroy

  scope :available, -> { where.not(status: :deleted) }
  scope :by_encrypted_id, ->(encrypted_id) { find(decrypt_id(encrypted_id)) }

  validates :settings, store_model: { merge_errors: true }
  validates :stripe, store_model: { merge_errors: true }

  validates :name,
            presence: true,
            uniqueness: {
              scope: :user_id,
              case_sensitive: false,
              conditions: -> { available },
              message: ALREADY_TAKEN_ERROR,
            }
  validates :domain,
            domain_url: true,
            presence: true,
            uniqueness: {
              scope: :user_id,
              # case_sensitive: false,
              conditions: -> { available },
              message: ALREADY_TAKEN_ERROR,
            },
            if: -> { domain_changed? }

  validate :validate_paths, if: -> { paths_changed? }
  validates :guidelines, length: { maximum: 500 }

  normalizes :name, with: ->(name) { name.strip }
  normalizes :domain, with: ->(domain) { domain.downcase }

  before_save if: -> { domain_changed? } do |project|
    project.domain = Project.parse_url(domain)&.host
  end

  def self.parse_url(url)
    Addressable::URI.parse([url.start_with?('http') ? '' : 'http://', url].join)
  end

  def free_plan_suspended? = free_plan? && status_suspended?

  # @return [Array<ProjectPath>]
  def smart_paths
    (self[:paths] || []).map { |path| ProjectPath.new(self, path) }
  end

  def decorate
    ProjectDecorator.new(self)
  end

  def valid_host?(host)
    host.to_s.delete_prefix('www.') == domain.to_s.delete_prefix('www.')
  end

  private

  def validate_paths
    paths.each do |path|
      Addressable::URI.parse(path)
    rescue StandardError => e
      errors.add(:paths, "#{path} #{e.message}")
    end
  end
end

# == Schema Information
#
# Table name: projects
#
#  id                    :bigint           not null, primary key
#  default_llm           :enum             default("gpt_4o_mini"), not null
#  deleted_at            :datetime
#  domain                :string           not null
#  free_clicks_threshold :integer          default(500), not null
#  guidelines            :text             default("")
#  name                  :string           default(""), not null
#  paths                 :jsonb            not null
#  plan                  :enum             default("free"), not null
#  protocol              :string           not null
#  settings              :jsonb            not null
#  status                :enum             default("active"), not null
#  stripe                :jsonb            not null
#  uuid                  :uuid             not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  subscription_id       :bigint
#  user_id               :bigint           not null
#
# Indexes
#
#  index_projects_on_created_at          (created_at)
#  index_projects_on_subscription_id     (subscription_id)
#  index_projects_on_user_id             (user_id)
#  index_projects_on_user_id_and_domain  (user_id,domain) UNIQUE WHERE (status <> 'deleted'::user_project_status)
#  index_projects_on_user_id_and_name    (user_id,name) UNIQUE WHERE (status <> 'deleted'::user_project_status)
#  index_projects_on_uuid                (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (subscription_id => project_subscriptions.id) ON DELETE => restrict ON UPDATE => cascade
#  fk_rails_...  (user_id => users.id) ON UPDATE => cascade
#
