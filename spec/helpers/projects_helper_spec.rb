# frozen_string_literal: true

RSpec.describe ProjectsHelper, type: :helper do
  include SpecTestHelper

  describe "project_list" do
    it "returns empty project list when user is not logged in" do
      allow(helper).to receive_messages(user_signed_in?: false)
      expect(helper.project_list).to eq []
    end

    it "returns project list when user is not logged in" do
      user = create_default_user
      allow(helper).to receive_messages(user_signed_in?: true, current_user: user)
      user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project 1')
      user.projects.create!(protocol: 'https', domain: 'localhostyy.com', name: 'Test Project 2')
      expect(helper.project_list.size).to eq 2
      expect(helper.project_list).to eq Project.select('id', 'name').where(user_id: user.id).order(:id).all
    end
  end
end
