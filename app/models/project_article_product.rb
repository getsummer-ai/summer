# frozen_string_literal: true
class ProjectArticleProduct < ApplicationRecord
  include EncryptedKey

  belongs_to :article, class_name: 'ProjectArticle', foreign_key: :project_article_id
  belongs_to :product, class_name: 'ProjectProduct', foreign_key: :project_product_id
  belongs_to :product_minimal_info,
             -> { only_main_columns.icon_as_base64 },
             class_name: 'ProjectProduct',
             foreign_key: :project_product_id

  scope :active, -> { where(is_accessible: true) }

  validates :product,
            presence: true,
            uniqueness: {
              scope: :project_article_id,
              message: 'already added',
            },
            if: -> { product_changed? }
end

# == Schema Information
#
# Table name: project_article_products
#
#  id                 :bigint           not null, primary key
#  is_accessible      :boolean          default(TRUE), not null
#  position           :integer          default(10), not null
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
