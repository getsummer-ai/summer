# frozen_string_literal: true

describe ProjectSuspensionService do
  include SpecTestHelper

  subject { described_class.new(project) }

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }
  
  describe '#actualize_status' do
    context 'when project has no subscription' do
      it 'does not change project status' do
        expect(Rails.logger).to \
          receive(:warn).with("ProjectSuspensionService: project without subscription: #{project.domain}")
        expect { subject.actualize_status }.not_to(change(project, :status))
      end
    end

    context 'when project has subscription' do
      it 'does not change project status when subscription is active' do
        create_default_subscription_for(
          project,
          start_at: Time.zone.now,
          end_at: 10.years.from_now,
          summarize_usage: 0,
          summarize_limit: 500
        )
        expect { subject.actualize_status }.not_to(change(project, :status))
      end

      it 'suspends project when subscription is not active' do
        create_default_subscription_for(
          project,
          start_at: 1.month.ago,
          end_at: Time.zone.now,
          summarize_usage: 0,
          summarize_limit: 500
        )
        expect { subject.actualize_status }.to change(project, :status).from('active').to('suspended')
      end

      it 'suspends project when subscription clicks limit is reached' do
        create_default_subscription_for(
          project,
          start_at: Time.zone.now,
          end_at: 10.years.from_now,
          summarize_usage: 501,
          summarize_limit: 500
        )
        expect { subject.actualize_status }.to change(project, :status).from('active').to('suspended')
      end
    end
  end

  describe '#suspend_project' do
    it 'suspends project' do
      expect { subject.suspend_project }.to change(project, :status).from('active').to('suspended')
    end

    it 'sends out of clicks email' do
      expect(ProjectMailer).to receive_message_chain(:out_of_clicks_suspension_notification, :deliver_now)
      subject.suspend_project(send_out_of_clicks_email: true)
    end
  end
end
