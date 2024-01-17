# frozen_string_literal: true

class Project < ApplicationRecord
  enum plan: { free: "free", paid: "paid" }
  enum status: { active: "active", suspended: "suspended", deleted: "deleted" }

  belongs_to :user
  has_many :project_urls, dependent: :destroy
  has_many :project_articles, dependent: :destroy
  has_many :project_article_statistics, through: :project_articles
end

# == Schema Information
#
# Table name: projects
#
#  id         :uuid             not null, primary key
#  deleted_at :datetime
#  domain     :string           not null
#  name       :string           default(""), not null
#  plan       :enum             default("free"), not null
#  settings   :jsonb
#  status     :enum             default("active"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_projects_on_created_at  (created_at)
#  index_projects_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
