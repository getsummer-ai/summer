# frozen_string_literal: true

RSpec.describe ProjectsHelper, type: :helper do
  describe "project_list" do
    it "returns empty project list when user is not logged in" do
      allow(helper).to receive_messages(user_signed_in?: false)
      expect(helper.project_list).to eq []
    end

    it "returns project list when user is not logged in" do
      user = User.create(
        email: 'admin@test.com',
        password: '12345678',
        password_confirmation: '12345678',
        confirmed_at: Time.zone.now
      )
      allow(helper).to receive_messages(user_signed_in?: true, current_user: user)
      user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project 1')
      user.projects.create!(protocol: 'https', domain: 'localhostyy.com', name: 'Test Project 2')
      expect(helper.project_list.size).to eq 2
      expect(helper.project_list).to eq Project.select('id', 'name').where(user_id: user.id).order(:id).all
    end
  end
end
