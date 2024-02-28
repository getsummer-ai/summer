# frozen_string_literal: true

class AvoProjectPage < ProjectPage
  has_many :events, class_name: 'AvoEvent', as: :trackable, dependent: :destroy
  belongs_to :project, class_name: 'AvoProject'
  belongs_to :project_article, class_name: 'AvoProjectArticle'

  before_destroy :stop_destroy

  def to_param
    id
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id url url_hash project_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[project project_article]
  end

  def stop_destroy
    errors.add(:base, :undestroyable)
    throw :abort
  end
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
#  index_project_pages_on_project_id_and_url_hash  (project_id,url_hash) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_article_id => project_articles.id) ON UPDATE => cascade
#  fk_rails_...  (project_id => projects.id) ON UPDATE => cascade
#
