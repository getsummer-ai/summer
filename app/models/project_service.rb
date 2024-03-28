# frozen_string_literal: true

class ProjectService < ApplicationRecord
  include EncryptedKey
  include Trackable

  belongs_to :project

  validates :title, presence: true
  validates :description, presence: true
  validates :link, domain_url: true, presence: true

  has_many :statistics, as: :trackable, class_name: 'ProjectStatistic', dependent: :destroy
  has_one :statistics_by_total, class_name: 'ProjectStatisticsByTotal', as: :trackable

  scope :skip_retrieving, ->(*v) { select(column_names.map(&:to_sym) - Array.wrap(v)) }

  store :info, accessors: %i[meta], coder: JsonbSerializer

  after_commit :retrieve_url, on: %i[create update], if: :link_previously_changed?

  private

  def retrieve_url
    ProjectServiceLinkScrapeJob.perform_later(id)
  end
end

# == Schema Information
#
# Table name: project_services
#
#  id            :bigint           not null, primary key
#  description   :string           not null
#  icon          :binary
#  info          :jsonb
#  is_accessible :boolean          default(TRUE), not null
#  link          :string           not null
#  title         :string           not null
#  uuid          :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  project_id    :bigint           not null
#
# Indexes
#
#  index_project_services_on_project_id           (project_id)
#  index_project_services_on_project_id_and_uuid  (project_id,uuid)
#  index_project_services_on_uuid                 (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade ON UPDATE => cascade
#
