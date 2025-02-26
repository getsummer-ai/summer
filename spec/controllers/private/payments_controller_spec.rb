# frozen_string_literal: true
RSpec.describe Private::PaymentsController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let!(:user) { create_default_user }
  let!(:project) do
    user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
  end
  let(:stripe_service) { instance_double(ProjectStripeService) }

  before do
    login_user(user)
    allow(ProjectStripeService).to receive(:new).and_return(stripe_service)
  end

  describe 'POST #create' do
    let(:stripe_session) { double('Stripe::Checkout::Session', url: 'http://example.com') }

    it 'redirects to the stripe session url' do
      allow(stripe_service).to receive_messages(
        stripe_customer: {},
        create_checkout_session: stripe_session,
      )

      post :create,
           params: {
             project_id: project.encrypted_id,
             subscription: {
               period: 'year',
               plan: 'basic',
             },
           }

      expect(response).to redirect_to(stripe_session.url)
      expect(controller.current_project).to eq(project)
    end
  end
end
