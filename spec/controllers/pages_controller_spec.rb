# frozen_string_literal: true
RSpec.describe PagesController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  before do
    login_user
  end

  describe "GET /index" do
    it "renders a successful response" do
      get :homepage
      expect(response).to be_successful
    end
  end

  describe "GET /about" do
    it "renders a successful response" do
      get :about
      expect(response).to be_successful
    end
  end
end
