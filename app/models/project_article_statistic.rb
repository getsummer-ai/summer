# frozen_string_literal: true

class ProjectArticleStatistic < ApplicationRecord
  belongs_to :project_article
end

# == Schema Information
#
# Table name: project_article_statistics
#
#  id                 :bigint           not null, primary key
#  clicks             :bigint           default(0), not null
#  date               :date             not null
#  hour               :integer          not null
#  views              :bigint           default(0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  project_article_id :bigint           not null
#  project_url_id     :bigint           not null
#
# Indexes
#
#  idx_on_project_article_id_project_url_id_date_hour_aee771512a  (project_article_id,project_url_id,date,hour) UNIQUE
#  index_project_article_statistics_on_date                       (date)
#  index_project_article_statistics_on_project_article_id         (project_article_id)
#  index_project_article_statistics_on_project_url_id             (project_url_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_article_id => project_articles.id) ON UPDATE => cascade
#  fk_rails_...  (project_url_id => project_urls.id) ON UPDATE => cascade
#
