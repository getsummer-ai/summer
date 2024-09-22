# frozen_string_literal: true

describe ProjectStripeService do
  include SpecTestHelper

  subject { described_class.new(project) }

  include_context 'with gpt requests'

  let!(:user) { create_default_user }
  let!(:project) do
    project = user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com')
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
    project
  end

  let(:stripe_subscription_interval) { :month }
  let(:stripe_subscription_plan) { :light }
  let(:stripe_subscription_period_start) { 1_727_022_567 }
  let(:stripe_subscription_period_end) { 1_729_614_567 }

  let(:stripe_subscription) do
    OpenStruct.new(
      id: 'sub_1P8ozmDm8NzUNvXDqCFVlxRQ',
      status: 'active',
      latest_invoice: 'in_1PJhJ7Dm8NzUNvXDjaFQrPni',
      plan:
        OpenStruct.new(
          livemode: false,
          id:
            ProjectStripeService::PLANS[:test][stripe_subscription_plan][
              stripe_subscription_interval
            ],
          interval: stripe_subscription_interval.to_s,
        ),
      cancel_at: nil,
      canceled_at: nil,
      current_period_start: stripe_subscription_period_start,
      current_period_end: stripe_subscription_period_end,
      start_date: stripe_subscription_period_start,
    )
  end

  before do
    session =
      OpenStruct.new(
        status: 'complete',
        metadata: OpenStruct.new(project_id: project.uuid),
        subscription: stripe_subscription.id,
      )

    allow(Stripe::Checkout::Session).to receive(:retrieve).and_return(session)
    allow(Stripe::Subscription).to receive(:retrieve).and_return(stripe_subscription)
  end

  describe '#session_success_callback' do
    it 'return true' do
      # expect(subject).to receive(:update_subscription_info).and_return(true)
      expect(subject.session_success_callback('random')).to be(true)
    end
  end

  describe '#update_subscription_info' do
    it 'works well' do
      expect(project.stripe.subscription.id).to be_nil
      expect(project.plan).to eq('free')
      expect(project.subscription.summarize_limit).to eq 10
      expect(project.subscription.summarize_usage).to eq 0
      expect(project.subscription.plan).to eq 'free'

      subject.update_subscription_info('random')

      expect(project.stripe.subscription.id).to eq('sub_1P8ozmDm8NzUNvXDqCFVlxRQ')
      expect(project.plan).to eq 'light'
      expect(project.subscription.summarize_limit).to eq 5000
      expect(project.subscription.summarize_usage).to eq 0
      expect(project.subscription.plan).to eq 'light'
    end
  end

  describe 'replaces subscription info with a new subscription for the same period' do
    let!(:project) do
      project =
        user.projects.create(name: 'Test', plan: 'light', protocol: 'http', domain: 'test.com')
      project
        .subscriptions
        .create!(
          plan: 'light',
          start_at: Time.at(stripe_subscription_period_start).utc,
          end_at: Time.at(stripe_subscription_period_end).utc,
          summarize_usage: 777,
          summarize_limit: 5000,
        )
        .tap { |s| project.update!(subscription: s) }
      project
    end

    let(:stripe_subscription_plan) { :pro }

    it 'works well' do
      expect(project.plan).to eq('light')
      expect(project.subscription.summarize_limit).to eq 5000
      expect(project.subscription.summarize_usage).to eq 777
      expect(project.subscription.plan).to eq 'light'
      expect(project.subscriptions.count).to eq 1

      subject.update_subscription_info('random')

      expect(project.stripe.subscription.id).to eq stripe_subscription.id
      expect(project.plan).to eq 'pro'
      expect(project.subscription.summarize_limit).to eq 25_000
      expect(project.subscription.summarize_usage).to eq 777
      expect(project.subscription.plan).to eq 'pro'
      expect(project.subscription.stripe).to eq stripe_subscription.as_json
      expect(project.subscriptions.count).to eq 1
    end
  end

  describe 'creates new project subscription info with new time period' do
    let!(:project) do
      project =
        user.projects.create(name: 'Test', plan: 'light', protocol: 'http', domain: 'test.com')
      project
        .subscriptions
        .create!(
          plan: 'light',
          start_at: Time.at(1_726_677_658).utc,
          end_at: Time.at(1_726_687_658).utc,
          summarize_usage: 777,
          summarize_limit: 5000,
        )
        .tap { |s| project.update!(subscription: s) }
      project
    end

    it 'works well' do
      expect(project.plan).to eq('light')
      expect(project.subscription.summarize_limit).to eq 5000
      expect(project.subscription.summarize_usage).to eq 777
      expect(project.subscription.plan).to eq 'light'
      expect(project.subscriptions.count).to eq 1

      subject.update_subscription_info('random')

      expect(project.stripe.subscription.id).to eq stripe_subscription.id
      expect(project.plan).to eq 'light'
      expect(project.subscription.summarize_limit).to eq 5_000
      expect(project.subscription.summarize_usage).to eq 0
      expect(project.subscription.plan).to eq 'light'
      expect(project.subscription.stripe).to eq stripe_subscription.as_json
      expect(project.subscriptions.count).to eq 2
    end
  end

  describe 'creates one year new project subscription with calculated summarize limit' do
    let(:stripe_subscription_interval) { :year }
    let(:stripe_subscription_plan) { :pro }
    let(:stripe_subscription_period_start) { Time.now.to_i }
    let(:stripe_subscription_period_end) { 1.year.from_now.to_i }

    it 'works well' do
      expect(project.plan).to eq('free')
      expect(project.subscriptions.count).to eq 1
      expect(Rails.logger).not_to receive(:error)

      subject.update_subscription_info('random')

      expect(project.stripe.subscription.id).to eq stripe_subscription.id
      expect(project.plan).to eq 'pro'
      expect(project.subscription.summarize_limit).to eq 25_000 * 12
      expect(project.subscription.summarize_usage).to eq 0
      expect(project.subscription.plan).to eq 'pro'
      expect(project.subscription.stripe).to eq stripe_subscription.as_json
      expect(project.subscriptions.count).to eq 2
    end
  end

  describe 'creates one year new project subscription with with a warning due to the wrong interval' do
    let(:stripe_subscription_period_start) { Time.now.to_i }
    let(:stripe_subscription_period_end) { 7.months.from_now.to_i }

    it 'calculated clicks limit properly and sends an error to the sentry' do
      expect(project.plan).to eq('free')
      expect(project.subscriptions.count).to eq 1

      expect(Sentry).to receive(:capture_message).with(
        'Wrong summarize limit',
        extra: {
          project_id: project.id,
          plan: :light,
          months: 7,
        },
      )

      expect(Rails.logger).to receive(:error).with(
        "Wrong summarize limit for project #{project.id} plan light months 7",
      )

      subject.update_subscription_info('random')

      expect(project.stripe.subscription.id).to eq stripe_subscription.id
      expect(project.plan).to eq 'light'
      expect(project.subscription.summarize_limit).to eq 5_000 * 7
      expect(project.subscription.summarize_usage).to eq 0
      expect(project.subscription.plan).to eq 'light'
      expect(project.subscription.stripe).to eq stripe_subscription.as_json
      expect(project.subscriptions.count).to eq 2
    end
  end
end
