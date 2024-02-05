# frozen_string_literal: true

class ProjectArticleUrl < ApplicationRecord
  belongs_to :project_article
  belongs_to :project_url
end

# == Schema Information
#
# Table name: project_article_urls
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  project_article_id :bigint           not null
#  project_url_id     :bigint           not null
#
# Indexes
#
#  index_project_article_urls_on_project_article_id  (project_article_id)
#  index_project_article_urls_on_project_url_id      (project_url_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_article_id => project_articles.id) ON UPDATE => cascade
#  fk_rails_...  (project_url_id => project_urls.id) ON UPDATE => cascade
#
