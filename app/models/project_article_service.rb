# frozen_string_literal: true
class ProjectArticleService < ApplicationRecord
  belongs_to :article, class_name: 'ProjectArticle', foreign_key: :project_article_id
  belongs_to :service, class_name: 'ProjectService', foreign_key: :project_service_id
end
