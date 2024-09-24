# frozen_string_literal: true

RSpec.describe "private/settings/index", type: :view do
  let!(:user) { create_default_user }
  let!(:project) do
    project = user.projects.create!(
      protocol: 'http',
      domain: 'localhost.com',
      name: 'Test Project'
    )
    create_default_subscription_for(project)
    project
  end

  before do
    request.path_parameters[:project_id] = project.id
    without_partial_double_verification do
      allow(view).to receive_messages(current_project: project)
    end
    assign(:current_project, project)
    assign(:statistics, double('statistics', result: []))
  end

  it "renders the page when a user has free sub" do
    render

    expect(rendered).to have_content("Settings")
    expect(rendered).to have_content("Light Plan")
    expect(rendered).to have_content("5 000 button clicks every month")
    expect(rendered).to have_content("Pro Plan")
    expect(rendered).to have_content("25 000 button clicks every month")
  end

  it "hides the subscription buttons when a user has the enterprise plan" do
    project.update!(plan: 'enterprise')
    render

    expect(rendered).to have_content("Settings")
    expect(rendered).not_to have_content("Light Plan")
    expect(rendered).not_to have_content("Pro Plan")
    expect(rendered).to have_content("Enterprise plan")
  end

  it "shows the Subscription button when a user has not enterprise plan" do
    project.update!(plan: 'pro', stripe_attributes: { customer_id: 'stripe_customer_id' })
    # project.subscription.update!(plan: 'pro')
    render

    expect(rendered).to have_content("Settings")
    expect(rendered).not_to have_content("Enterprise plan")
    expect(rendered).not_to have_content("Light Plan")
    expect(rendered).to have_text("Pro plan is active.", normalize_ws: true)
    expect(rendered).to have_button("Subscription")
  end

  it "does not show the Subscription button as a user does not have stipe_customer_id" do
    project.update!(plan: 'pro')
    render

    expect(rendered).not_to have_content("Enterprise plan")
    expect(rendered).not_to have_button("Subscription")


    expect(rendered).to have_content("Light Plan")
    expect(rendered).to have_content("5 000 button clicks every month")

    expect(rendered).to have_content("Pro Plan")
    expect(rendered).to have_content("25 000 button clicks every month")

    expect(rendered).to have_text("Pro plan is active.", normalize_ws: true)
  end

  it "does not show the Subscription button as a user has expired subscription" do
    project.update!(plan: 'pro', status: 'suspended', stripe_attributes: { customer_id: 'stripe_customer_id' })
    project.subscription.update!(end_at: 1.minute.ago)
    render

    expect(rendered).not_to have_content("Enterprise plan")
    expect(rendered).not_to have_button("Subscription")

    expect(rendered).to have_content("Light Plan")
    expect(rendered).to have_content("5 000 button clicks every month")

    expect(rendered).to have_content("Pro Plan")
    expect(rendered).to have_content("25 000 button clicks every month")

    expect(rendered).to have_text("Pro plan has been suspended.", normalize_ws: true)
  end

  context 'when subscription is canceled' do
    it "shows all the subs buttons and the information about when the sub was suspended" do
      project.update!(plan: 'pro', status: 'suspended', stripe_attributes: { customer_id: 'stripe_customer_id' })
      cancel_at = 1.minute.ago
      project.subscription.update!(cancel_at: )
      render

      expect(rendered).not_to have_content("Enterprise plan")
      expect(rendered).not_to have_button("Subscription")

      expect(rendered).to have_content("Light Plan")
      expect(rendered).to have_content("5 000 button clicks every month")

      expect(rendered).to have_text("Pro plan was suspended on #{cancel_at.strftime('%d %B %Y')}", normalize_ws: true)
    end

    it "shows the Subscription button and the information about when the sub was expired" do
      project.update!(plan: 'pro', status: 'active', stripe_attributes: { customer_id: 'stripe_customer_id' })
      cancel_at = 1.minute.ago
      project.subscription.update!(cancel_at: )
      render

      expect(rendered).not_to have_content("Enterprise plan")
      expect(rendered).not_to have_button("Subscription")

      expect(rendered).to have_content("Light Plan")
      expect(rendered).to have_content("5 000 button clicks every month")

      expect(rendered).to have_text("Pro plan was expired on #{cancel_at.strftime('%d %B %Y')}", normalize_ws: true)
    end

    it "shows the Subscription button and the information about when the sub ends" do
      project.update!(plan: 'pro', status: 'suspended', stripe_attributes: { customer_id: 'stripe_customer_id' })
      cancel_at = 1.minute.from_now
      project.subscription.update!(cancel_at: )
      render

      expect(rendered).to have_button("Subscription")

      expect(rendered).not_to have_content("Enterprise plan")
      expect(rendered).not_to have_content("Light Plan")
      expect(rendered).not_to have_content("5 000 button clicks every month")

      expect(rendered).not_to have_content("Pro Plan")
      expect(rendered).not_to have_content("25 000 button clicks every month")

      expect(rendered).to have_text("Pro plan ends on #{cancel_at.strftime('%d %B %Y')}", normalize_ws: true)
    end

    it "shows the Subscription button and the information about when the sub expires" do
      project.update!(plan: 'pro', status: 'active', stripe_attributes: { customer_id: 'stripe_customer_id' })
      cancel_at = 1.minute.from_now
      project.subscription.update!(cancel_at: )
      render

      expect(rendered).to have_button("Subscription")
      expect(rendered).to have_text("Pro plan expires on #{cancel_at.strftime('%d %B %Y')}", normalize_ws: true)
    end
  end
end
