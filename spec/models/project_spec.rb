# frozen_string_literal: true

describe 'Project' do
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
