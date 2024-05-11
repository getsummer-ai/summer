# frozen_string_literal: true

class ProjectProduct < ApplicationRecord
  include EncryptedKey
  include Trackable

  belongs_to :project

  validates :name, presence: true
  validates :description, presence: true
  validates :link, url: true, presence: true

  validates :name, uniqueness: { scope: [:project_id] }, if: -> { errors.empty? }

  has_many :statistics, as: :trackable, class_name: 'ProjectStatistic', dependent: :destroy
  has_one :statistics_by_total, class_name: 'ProjectStatisticsByTotal', as: :trackable

  scope :only_main_columns, -> { select(%w[id name description uuid link]) }
  scope :icon_as_base64, -> { select("encode(icon, 'base64') as icon") }
  scope :skip_retrieving, ->(*v) { select(column_names.map(&:to_sym) - Array.wrap(v)) }

  store :info, accessors: %i[meta], coder: JsonbSerializer
end

# == Schema Information
#
# Table name: project_products
#
#  id            :bigint           not null, primary key
#  description   :string           not null
#  icon          :binary
#  info          :jsonb
#  is_accessible :boolean          default(TRUE), not null
#  link          :string           not null
#  name          :string           not null
#  uuid          :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  project_id    :bigint           not null
#
# Indexes
#
#  index_project_products_on_project_id           (project_id)
#  index_project_products_on_project_id_and_uuid  (project_id,uuid)
#  index_project_products_on_uuid                 (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade ON UPDATE => cascade
#
