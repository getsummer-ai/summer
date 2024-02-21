# frozen_string_literal: true
RSpec.describe Api::V1::ButtonController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let(:project) do
    user =
      User.create(
        email: 'admin@test.ru',
        password: '12345678',
        password_confirmation: '12345678',
        confirmed_at: Time.zone.now,
      )
    user.projects.create!(domain: 'localhost.com', name: 'Test Project')
  end

  describe 'POST /init' do
    it 'returns Invalid Api-Key response' do
      request.headers['Api-Key'] = project.id
      post(:init, body: { s: 'http://localhost:3000/new-year-celebrations' })
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to eq "{\"message\":\"Invalid Api-Key\"}"
    end
  end
end
