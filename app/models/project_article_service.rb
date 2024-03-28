# frozen_string_literal: true
class ProjectArticleService < ApplicationRecord
  belongs_to :article, class_name: 'ProjectArticle', foreign_key: :project_article_id
  belongs_to :service, class_name: 'ProjectService', foreign_key: :project_service_id
end

# == Schema Information
#
# Table name: project_article_services
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  project_article_id :bigint           not null
#  project_service_id :bigint           not null
#
# Indexes
#
#  idx_on_project_article_id_project_service_id_cba9cb8a1d  (project_article_id,project_service_id) UNIQUE
#  index_project_article_services_on_project_article_id     (project_article_id)
#  index_project_article_services_on_project_service_id     (project_service_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_article_id => project_articles.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (project_service_id => project_services.id) ON DELETE => cascade ON UPDATE => cascade
#
