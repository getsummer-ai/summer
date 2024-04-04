# frozen_string_literal: true
class ProjectArticleProduct < ApplicationRecord
  belongs_to :article, class_name: 'ProjectArticle', foreign_key: :project_article_id
  belongs_to :product, class_name: 'ProjectProduct', foreign_key: :project_product_id
end

# == Schema Information
#
# Table name: project_article_products
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  project_article_id :bigint           not null
#  project_product_id :bigint           not null
#
# Indexes
#
#  idx_on_project_article_id_project_product_id_4f7270e242  (project_article_id,project_product_id) UNIQUE
#  index_project_article_products_on_project_article_id     (project_article_id)
#  index_project_article_products_on_project_product_id     (project_product_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_article_id => project_articles.id) ON DELETE => cascade ON UPDATE => cascade
#  fk_rails_...  (project_product_id => project_products.id) ON DELETE => cascade ON UPDATE => cascade
#
