# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id              :bigint           not null, primary key
#  default_llm     :enum             default("gpt_4o_mini"), not null
#  deleted_at      :datetime
#  domain          :string           not null
#  guidelines      :text             default("")
#  name            :string           default(""), not null
#  paths           :jsonb            not null
#  plan            :enum             default("free"), not null
#  protocol        :string           not null
#  settings        :jsonb            not null
#  status          :enum             default("active"), not null
#  stripe          :jsonb            not null
#  uuid            :uuid             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  subscription_id :bigint
#  user_id         :bigint           not null
#
# Indexes
#
#  index_projects_on_created_at          (created_at)
#  index_projects_on_subscription_id     (subscription_id)
#  index_projects_on_user_id             (user_id)
#  index_projects_on_user_id_and_domain  (user_id,domain) UNIQUE WHERE (status <> 'deleted'::user_project_status)
#  index_projects_on_user_id_and_name    (user_id,name) UNIQUE WHERE (status <> 'deleted'::user_project_status)
#  index_projects_on_uuid                (uuid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (subscription_id => project_subscriptions.id) ON DELETE => restrict ON UPDATE => cascade
#  fk_rails_...  (user_id => users.id) ON UPDATE => cascade
#
describe Project do
  include SpecTestHelper

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }

  describe '#settings' do
    it 'update via assign_attributes works' do
      project.reload
      project.update(settings_attributes: { 'feature_suggestion_attributes' => {"enabled"=>"0"}})
      project.save!
      
      expect(project.reload.settings.to_json).to include '"feature_suggestion":{"enabled":false}'
    end
  end
end
