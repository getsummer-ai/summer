# frozen_string_literal: true

describe ProjectUser do
  include SpecTestHelper
  # ActiveRecord::Base.logger = Logger.new(STDOUT)

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }

  describe 'validations' do
    it 'validates uniqueness of owner role per project' do
      user1 = create_default_user(email: Faker::Internet.email)
      user2 = create_default_user(email: Faker::Internet.email)
      project.project_users.create(user: user1, role: :owner)
      expect(project.project_users.create(user: user2, role: :owner)).not_to be_valid
    end
  end

  describe 'associations' do
    it 'check all the associations' do
      project_user = project.project_users.first
      expect(project_user.user).to eq user
      expect(project_user.project).to eq project
    end
  end


  describe '#send_invitation' do
    let(:project_user) { project.project_users.take }

    before do
      project_user.update!(invited_email_address: Faker::Internet.email, user_id: nil)
      allow(ProjectMailer).to receive_message_chain(:added_user_invitation_email, :deliver_now)
    end

    it 'sends invitation email and updates invitation_sent_at' do
      expect(ProjectMailer).to receive_message_chain(:added_user_invitation_email, :deliver_now)
      expect { project_user.send_invitation }
        .to change { project_user.reload.invitation_sent_at }.from(nil)
    end

    it 'does not send if invited_email_address is blank' do
      project_user.update!(invited_email_address: nil)
      expect(ProjectMailer).not_to receive(:added_user_invitation_email)
      expect { project_user.send_invitation }
        .not_to change { project_user.reload.invitation_sent_at }
    end

    it 'does not send if user_id is present' do
      project_user.update!(user_id: user.id)
      expect(ProjectMailer).not_to receive(:added_user_invitation_email)
      expect { project_user.send_invitation }
        .not_to change { project_user.reload.invitation_sent_at }
    end
  end
end
