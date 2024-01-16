# frozen_string_literal: true

RSpec.describe TurboModalComponent, type: :component do
  # pending "add some examples to (or delete) #{__FILE__}"

  it "renders something useful" do
    render_inline(described_class.new(title: 'Login', show_buttons: true)) { "Modal body" }

    expect(page).to have_text "Login"
    expect(page).to have_text "Cancel"
    expect(page).to have_text "Modal body"
  end
end
