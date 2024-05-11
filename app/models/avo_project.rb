# frozen_string_literal: true

class AvoProject < Project
  has_many :all_events, class_name: 'AvoEvent', foreign_key: 'project_id'
  has_many :project_pages, class_name: 'AvoProjectPage', foreign_key: 'project_id'
  has_many :project_articles, class_name: 'AvoProjectArticle', foreign_key: 'project_id'
  belongs_to :user, class_name: 'AvoUser'

  before_destroy :stop_destroy

  def to_param
    id
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[domain id name]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[all_events events project_article_statistics project_articles project_urls user]
  end


  def stop_destroy
    errors.add(:base, :undestroyable)
    throw :abort
  end
end

# == Schema Information
#
# Table name: projects
#
#  id          :bigint           not null, primary key
#  default_llm :enum             default("gpt3"), not null
#  deleted_at  :datetime
#  domain      :string           not null
#  guidelines  :text             default("")
#  name        :string           default(""), not null
#  paths       :jsonb            not null
#  plan        :enum             default("free"), not null
#  protocol    :string           not null
#  settings    :jsonb            not null
#  status      :enum             default("active"), not null
#  stripe      :jsonb            not null
#  uuid        :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_projects_on_created_at          (created_at)
#  index_projects_on_user_id             (user_id)
#  index_projects_on_user_id_and_domain  (user_id,domain) UNIQUE WHERE (status <> 'deleted'::user_project_status)
#  index_projects_on_user_id_and_name    (user_id,name) UNIQUE WHERE (status <> 'deleted'::user_project_status)
#  index_projects_on_uuid                (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON UPDATE => cascade
#
