# frozen_string_literal: true

RSpec.describe User, type: :model do
  include SpecTestHelper

  describe '#attach_to_projects_if_there_are_invitations' do
    let!(:user) { create_default_user }
    let!(:user_project) { create_default_project_for(user) }

    it 'attaches user to project invitations matching their email' do
      project_user = ProjectUser.create!(project: user_project, invited_email_address: 'invitee@example.com')
      expect(project_user.user_id).to be_nil
      expect_any_instance_of(User).to receive(:attach_to_projects_if_there_are_invitations).and_call_original
      invitee_user = create_default_user(email: 'invitee@example.com')
      project_user.reload
      expect(project_user.user_id).to eq invitee_user.id
    end

    it 'does not attach if there are no matching invitations' do
      project_user = ProjectUser.create!(project: user_project, invited_email_address: 'inv@example.com')
      expect { create_default_user(email: 'invitee@example.com') }.not_to(change { project_user.user_id })
    end
  end
end
