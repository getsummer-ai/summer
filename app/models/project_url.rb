# frozen_string_literal: true

class ProjectUrl < ApplicationRecord
  belongs_to :project
  has_many :project_article_urls, dependent: :destroy
  has_many :project_articles, through: :project_article_urls

  validates :url_hash, presence: true, uniqueness: {
    scope: [:project_id]
  }
end

# == Schema Information
#
# Table name: project_urls
#
#  id         :bigint           not null, primary key
#  url        :string           not null
#  url_hash   :string           not null
#  created_at :datetime         not null
#  project_id :uuid             not null
#
# Indexes
#
#  index_project_urls_on_project_id               (project_id)
#  index_project_urls_on_project_id_and_url_hash  (project_id,url_hash) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
