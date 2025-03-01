# frozen_string_literal: true

class ProjectApiKey < ApplicationRecord
  belongs_to :project, optional: true
  belongs_to :owner, class_name: 'User', optional: true

  enum :key_type, { default: 'default', framer: 'framer' }
end

# == Schema Information
#
# Table name: project_api_keys
#
#  id           :uuid             not null, primary key
#  activated_at :datetime
#  details      :jsonb            not null
#  expired_at   :datetime
#  key_type     :enum             default("default"), not null
#  last_used_at :datetime
#  usage_count  :integer          default(0), not null
#  created_at   :datetime         not null
#  owner_id     :bigint
#  project_id   :bigint
#
# Indexes
#
#  index_project_api_keys_on_owner_id    (owner_id)
#  index_project_api_keys_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#  fk_rails_...  (project_id => projects.id)
#
