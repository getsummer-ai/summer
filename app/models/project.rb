# frozen_string_literal: true

class Project < ApplicationRecord
  include Trackable
  enum plan: { free: 'free', paid: 'paid' }
  enum status: { active: 'active', suspended: 'suspended', deleted: 'deleted' }

  # I'm using the overhead way because the IDE does not show the highlight on store_accessor.
  # store_accessor :settings, %i[color font_size url_filter container_id], prefix: true
  store :settings,
        accessors: %i[color font_size url_filter container_id],
        coder: JsonbSerializer,
        prefix: true

  belongs_to :user
  has_many :project_urls, dependent: :destroy
  has_many :project_articles, dependent: :destroy
  has_many :project_article_statistics, through: :project_articles

  validates :name,
            presence: true,
            uniqueness: {
              scope: :user_id,
              message: 'You already have a project with this name',
            }
  validates :domain,
            domain_url: true,
            presence: true,
            uniqueness: {
              scope: :user_id,
              message: 'You already have a project with this domain',
            }
  validates :settings_container_id,
            allow_blank: true,
            format: {
              with: /\A[a-zA-Z][\w:.-]*\z/,
              message: "Only html ID name is allowed. Example: 'article-container'",
            }
  validates :settings_url_filter,
            allow_blank: true,
            format: {
              with: %r{\A/[\w-]*/\z},
              message: "Only url path is allowed. Example: '/blog/'",
            }

  normalizes :name, with: ->(name) { name.strip }
  # normalizes :settings_container_id, with: ->(container_id) { container_id.to_s.downcase }
  # normalizes :settings_container_id, apply_to_nil: true, with: ->(v) { v }
  # normalizes :settings_url_filter, apply_to_nil: true, with: ->(v) { v }

  before_save :normalize_domain

  alias project_id id

  def to_param
    encrypted_id
  end

  #
  # before_update do
  #   # We set trackable_type: 'Customer' because our events association is not from trackable module
  #   # (association events - has been overwritten to get all events related to customer)
  #   options = _tracking_options.merge({ trackable_type: 'Customer', trackable_uuid: try(:id) })
  #   # If we call "track!" before this callback, then we need to set a source
  #   options[:source] = 'Customer#before_update' unless _instance_tracking
  #   start_tracking(options)
  # end

  def self.host_from_url(url)
    prefix = 'http://'
    prefix = '' if url.start_with?('http')
    Addressable::URI.parse([prefix, url].join).host
  end

  def encrypted_id
    return nil if id.nil?
    @encrypted_id ||= BasicEncrypting.encode(id)
  end

  private

  def normalize_domain
    return if domain.nil? || !domain_changed?
    # self.domain = PublicSuffix.domain(domain) and return if PublicSuffix.valid?(domain)
    self.domain = self.class.host_from_url(domain)
  end
end

# == Schema Information
#
# Table name: projects
#
#  id         :bigint           not null, primary key
#  deleted_at :datetime
#  domain     :string           not null
#  name       :string           default(""), not null
#  plan       :enum             default("free"), not null
#  settings   :jsonb
#  status     :enum             default("active"), not null
#  uuid       :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_projects_on_created_at          (created_at)
#  index_projects_on_user_id             (user_id)
#  index_projects_on_user_id_and_domain  (user_id,domain) UNIQUE
#  index_projects_on_user_id_and_name    (user_id,name) UNIQUE
#  index_projects_on_uuid                (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
