# frozen_string_literal: true

# @!attribute settings
#  @return [ProjectSettings]
# @!attribute stripe
#  @return [ProjectStripeDetails]
class Project < ApplicationRecord
  include StoreModel::NestedAttributes
  include Trackable
  include EncryptedKey
  enum plan: { free: 'free', paid: 'paid' }, _suffix: true
  enum status: { active: 'active', suspended: 'suspended', deleted: 'deleted' }, _prefix: true
  enum default_llm: { gpt3: 'gpt3.5', gpt4: 'gpt4' }, _prefix: true

  # I'm using the overhead way because the IDE does not show the highlight on store_accessor.
  # store_accessor :settings, %i[theme font_size container_id], prefix: true
  # store :settings, accessors: %i[theme container_id], coder: JsonbSerializer, prefix: true
  # store_accessor :settings, :feature_suggestion, :feature_subscription

  # store_accessor :feature_suggestion, :enabled, prefix: true
  # store_accessor :feature_subscription, :enabled, prefix: true

  # attribute :feature_suggestion, :jsonb
  # attribute :feature_subscription, :jsonb

  attribute :settings, ProjectSettings.to_type
  attribute :stripe, ProjectStripeDetails.to_type
  accepts_nested_attributes_for :settings, allow_destroy: false
  accepts_nested_attributes_for :stripe, allow_destroy: false

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
              conditions: -> { where.not(status: :deleted) },
              message: 'is already taken',
            }
  validates :domain,
            domain_url: true,
            presence: true,
            uniqueness: {
              scope: :user_id,
              case_sensitive: false,
              conditions: -> { where.not(status: :deleted) },
              message: 'is already taken',
            },
            if: -> { domain_changed? }

  validate :validate_paths, if: -> { paths_changed? }
  validates :guidelines, length: { maximum: 500 }

  normalizes :name, with: ->(name) { name.strip }

  before_save if: -> { domain_changed? } do |project|
    project.domain = Project.parse_url(domain)&.host
  end

  def self.parse_url(url)
    Addressable::URI.parse([url.start_with?('http') ? '' : 'http://', url].join)
  end

  def free_plan_active? = free_plan? && status_active?
  def free_plan_suspended? = free_plan? && status_suspended?
  def paid_plan_active? = paid_plan? && status_active?
  def paid_plan_suspended? = paid_plan? && status_suspended?

  # @return [Array<ProjectPath>]
  def smart_paths
    (self[:paths] || []).map { |path| ProjectPath.new(self, path) }
  end

  def decorate
    ProjectDecorator.new(self)
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
#  id          :bigint           not null, primary key
#  default_llm :enum             default("gpt3"), not null
#  deleted_at  :datetime
#  domain      :string           not null
#  guidelines  :text             default("")
#  name        :string           default(""), not null
#  paths       :jsonb            not null
#  plan        :enum             default("free"), not null
#  protocol    :string           not null
#  settings    :jsonb            not null
#  status      :enum             default("active"), not null
#  stripe      :jsonb            not null
#  uuid        :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_projects_on_created_at          (created_at)
#  index_projects_on_user_id             (user_id)
#  index_projects_on_user_id_and_domain  (user_id,domain) UNIQUE WHERE (status <> 'deleted'::user_project_status)
#  index_projects_on_user_id_and_name    (user_id,name) UNIQUE WHERE (status <> 'deleted'::user_project_status)
#  index_projects_on_uuid                (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON UPDATE => cascade
#
