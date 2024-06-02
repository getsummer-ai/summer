# frozen_string_literal: true

describe ProjectStripeService do
  include SpecTestHelper

  subject { described_class.new(project) }

  include_context 'with gpt requests'

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }

  before do
    subscription =
    OpenStruct.new(
        id: 'sub_1P8ozmDm8NzUNvXDqCFVlxRQ',
        status: 'active',
        latest_invoice: 'in_1PJhJ7Dm8NzUNvXDjaFQrPni',
        plan: OpenStruct.new(
          livemode: false,
          id: ProjectStripeService::PLANS[:test][:light][:year],
          interval: 'year',
        ),
        cancel_at: nil,
        canceled_at: nil,
        start_date: 1_713_900_434
      )

    session =
      OpenStruct.new(
        status: 'complete',
        metadata: OpenStruct.new(project_id: project.uuid),
        subscription: subscription.id,
      )

    allow(Stripe::Checkout::Session).to receive(:retrieve).and_return(session)
    allow(Stripe::Subscription).to receive(:retrieve).and_return(subscription)
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

      subject.update_subscription_info('random')

      expect(project.stripe.subscription.id).to eq('sub_1P8ozmDm8NzUNvXDqCFVlxRQ')
      expect(project.plan).to eq('light')
    end
  end
end
