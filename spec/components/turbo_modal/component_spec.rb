# frozen_string_literal: true

RSpec.describe TurboModal::Component, type: :component do
  # pending "add some examples to (or delete) #{__FILE__}"

  it "renders something useful" do
    render_inline(described_class.new(title: 'Login')) { "Modal body" }

    expect(page).to have_text "Login"
    expect(page).to have_text "Modal body"
  end

  it "renders something useful and go back button" do
    render_inline(described_class.new(title: 'ANOTHER TITLE', go_back_path: '/')) { "Modal body" }

    expect(page).to have_text "ANOTHER TITLE"
    expect(page).to have_link "Back", href: '/'
    expect(page).to have_text "Modal body"
  end
end
