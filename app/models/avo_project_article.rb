# frozen_string_literal: true

class AvoProjectArticle < ProjectArticle
  has_many :events, class_name: 'AvoEvent', as: :trackable, dependent: :destroy
  belongs_to :project, class_name: 'AvoProject'
  has_many :project_urls, class_name: 'AvoProjectUrl', foreign_key: 'project_article_id'

  before_destroy :stop_destroy

  def to_param
    id
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id title article_hash]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[project project_urls]
  end

  def stop_destroy
    errors.add(:base, :undestroyable)
    throw :abort
  end
end

# == Schema Information
#
# Table name: project_articles
#
#  id               :bigint           not null, primary key
#  article          :text             not null
#  article_hash     :string           not null
#  image_url        :text
#  info             :jsonb
#  last_modified_at :datetime
#  last_scraped_at  :datetime
#  status_services  :enum             default("wait"), not null
#  status_summary   :enum             default("wait"), not null
#  title            :text
#  tokens_count     :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  project_id       :bigint           not null
#
# Indexes
#
#  index_project_articles_on_project_id                   (project_id)
#  index_project_articles_on_project_id_and_article_hash  (project_id,article_hash) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
