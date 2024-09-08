# frozen_string_literal: true

class ProjectSubscription < ApplicationRecord
  # include StoreModel::NestedAttributes
  include Trackable

  belongs_to :project
end

# == Schema Information
#
# Table name: project_subscriptions
#
#  id              :bigint           not null, primary key
#  cancel_at       :datetime
#  end_at          :datetime         not null
#  plan            :enum             not null
#  start_at        :datetime         not null
#  stripe          :jsonb            not null
#  summarize_limit :integer          not null
#  summarize_usage :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  project_id      :bigint           not null
#
# Indexes
#
#  idx_on_project_id_start_at_end_at_7316c90a1e  (project_id,start_at,end_at) UNIQUE
#  index_project_subscriptions_on_project_id     (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade ON UPDATE => cascade
#
