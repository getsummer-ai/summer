# frozen_string_literal: true

class ProjectPage < ApplicationRecord
  include Trackable
  include EncryptedKey

  belongs_to :project
  belongs_to :article, class_name: 'ProjectArticle', foreign_key: 'project_article_id', inverse_of: :pages

  belongs_to :article_minimal_info,
             -> { select(%w[id title summary_status products_status]) },
             class_name: "ProjectArticle",
             foreign_key: "project_article_id",
             inverse_of: :pages

  has_one :statistics_by_total,
          class_name: "ProjectStatisticsByTotal",
          as: :trackable

  has_many :statistics_by_months,
          class_name: "ProjectStatisticsByMonth",
          as: :trackable

  validates :url_hash, presence: true, uniqueness: {
    scope: [:project_id]
  }

  # def to_param
  #   url_hash
  # end
end

# == Schema Information
#
# Table name: project_pages
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
#  index_project_pages_on_project_article_id       (project_article_id)
#  index_project_pages_on_project_id               (project_id)
#  index_project_pages_on_project_id_and_url       (project_id,url) UNIQUE
#  index_project_pages_on_project_id_and_url_hash  (project_id,url_hash) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_article_id => project_articles.id) ON UPDATE => cascade
#  fk_rails_...  (project_id => projects.id) ON UPDATE => cascade
#
