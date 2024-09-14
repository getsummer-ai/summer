# frozen_string_literal: true

describe SuspendProjectsJob do
  include SpecTestHelper

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create!(name: 't', protocol: 'http', domain: 'test.co') }
  let!(:subscription) do
    project
      .subscriptions
      .create!(
        plan: 'free',
        start_at: project.created_at,
        end_at: '2038-01-01 00:00:00',
        summarize_usage: 0,
        summarize_limit: 10,
      )
      .tap { |s| project.update!(subscription: s) }
  end
  let!(:article) { project.articles.create!(article_hash: '354', article: 'On the...') }
  let!(:page) do
    project.pages.create!(url: 'http://localhost:3000/random', url_hash: 'random', article:)
  end
  let(:time) { Time.now.utc }

  describe '#perform' do
    it 'does not suspend project' do
      expect(project.status).to eq('active')
      expect { described_class.perform }.not_to(change { ActionMailer::Base.deliveries.size })
      expect(project.reload.status).to eq('active')
    end

    it 'does not activate project when it has suspended due to usage limits' do
      project.subscription.update(summarize_usage: 10)
      project.update!(status: 'suspended')
      expect { described_class.perform }.not_to(change { ActionMailer::Base.deliveries.size })
      expect(project.reload.status).to eq('suspended')
    end

    it 'does not activate the project when a subscription has expired' do
      project.subscription.update(summarize_limit: 5_000, summarize_usage: 0, end_at: 1.second.ago)
      project.update!(status: 'suspended')
      expect { described_class.perform }.not_to(change { ActionMailer::Base.deliveries.size })
      expect(project.reload.status).to eq('suspended')
    end

    it 'does not activate the project if the subscription has exceeded the cancellation time' do
      project.subscription.update(
        summarize_limit: 5_000,
        summarize_usage: 0,
        end_at: 1.month.from_now,
        cancel_at: 1.second.ago,
      )
      project.update!(status: 'suspended')
      expect { described_class.perform }.not_to(change { ActionMailer::Base.deliveries.size })
      expect(project.reload.status).to eq('suspended')
    end

    it 'suspends free plan project' do
      time = Time.now.utc
      project.subscription.update(summarize_usage: 10)

      # create statistics for the project
      # because it's used within the free_plan_suspension_notification email
      project.statistics.create!(
        trackable: page,
        date: time.to_date,
        hour: time.hour,
        views: 10,
        clicks: 10,
      )

      expect(project.status).to eq('active')
      expect { described_class.perform }.to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(project.reload.status).to eq('suspended')
      expect(project.plan).to eq('free')

      expect(ActionMailer::Base.deliveries.last.body.raw_source).to include(
        'Take a look what you’ve achieved with your free trial',
      )
    end

    it 'suspends light plan project' do
      project.subscription.update(plan: 'light', summarize_limit: 3888, summarize_usage: 4000)

      expect(project.status).to eq('active')
      expect { described_class.perform }.to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(project.reload.status).to eq('suspended')
      expect(project.subscription.plan).to eq('light')

      expect(ActionMailer::Base.deliveries.last.body.raw_source).to include(
        'The Light plan includes a 3,888 clicks limit.',
      )
    end

    it 'suspends pro plan project' do
      project.subscription.update(plan: 'pro', summarize_limit: 19_000, summarize_usage: 25_000)

      expect(project.status).to eq('active')
      expect { described_class.perform }.to change { ActionMailer::Base.deliveries.size }.by(1)
      expect(project.reload.status).to eq('suspended')

      expect(ActionMailer::Base.deliveries.last.body.raw_source).to include(
        'and has reached its Pro plan 19,000 clicks limit.',
      )
    end

    it 'suspends project due to a subscription ends without sending an out of click email' do
      project.subscription.update(
        plan: 'light',
        summarize_limit: 3888,
        summarize_usage: 3000,
        end_at: 1.second.ago,
      )

      expect(project.status).to eq('active')
      expect { described_class.perform }.not_to(change { ActionMailer::Base.deliveries.size })
      expect(project.reload.status).to eq('suspended')
      expect(project.subscription.plan).to eq('light')
    end

    it 'suspends project due to a cancel date without sending an out of click email' do
      project.subscription.update(
        plan: 'light',
        summarize_limit: 3888,
        summarize_usage: 3000,
        cancel_at: 1.second.ago,
      )

      expect(project.status).to eq('active')
      expect { described_class.perform }.not_to(change { ActionMailer::Base.deliveries.size })
      expect(project.reload.status).to eq('suspended')
      expect(project.subscription.plan).to eq('light')
    end

    it 'activates project when a new subscription appears' do
      project.subscription.update(plan: 'light', summarize_limit: 5_000, summarize_usage: 0)
      project.update!(status: 'suspended')
      expect { described_class.perform }.not_to(change { ActionMailer::Base.deliveries.size })
      expect(project.reload.status).to eq('active')
    end
  end
end
