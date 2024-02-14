# frozen_string_literal: true

class ProjectUrl < ApplicationRecord
  belongs_to :project
  belongs_to :project_article

  validates :url_hash, presence: true, uniqueness: {
    scope: [:project_id]
  }
end

# == Schema Information
#
# Table name: project_urls
#
#  id                 :bigint           not null, primary key
#  is_accessible      :boolean          default(TRUE), not null
#  url                :string           not null
#  url_hash           :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  project_article_id :bigint           not null
#  project_id         :bigint           not null
#
# Indexes
#
#  index_project_urls_on_project_article_id       (project_article_id)
#  index_project_urls_on_project_id               (project_id)
#  index_project_urls_on_project_id_and_url_hash  (project_id,url_hash) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_article_id => project_articles.id) ON UPDATE => cascade
#  fk_rails_...  (project_id => projects.id) ON UPDATE => cascade
#
