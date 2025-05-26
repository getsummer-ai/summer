# frozen_string_literal: true

describe ProjectUser do
  include SpecTestHelper
  # ActiveRecord::Base.logger = Logger.new(STDOUT)

  let!(:user) { create_default_user }
  let!(:project) { user.projects.create(name: 'Test', protocol: 'http', domain: 'test.com') }

  describe 'validations' do
    it 'validates uniqueness of owner role per project' do
      user1 = create_default_user(email: Faker::Internet.email)
      user2 = create_default_user(email: Faker::Internet.email)
      project.project_users.create(user: user1, role: :owner)
      expect(project.project_users.create(user: user2, role: :owner)).not_to be_valid
    end
  end

  describe 'associations' do
    it 'check all the associations' do
      project_user = project.project_users.first
      expect(project_user.user).to eq user
      expect(project_user.project).to eq project
    end
  end
end
