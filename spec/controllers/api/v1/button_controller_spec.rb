# frozen_string_literal: true
RSpec.describe Api::V1::ButtonController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let!(:project) do
    user =
      User.create(
        email: 'admin@test.ru',
        password: '12345678',
        password_confirmation: '12345678',
        confirmed_at: Time.zone.now,
      )
    user.projects.create!(domain: 'localhost.com', name: 'Test Project')
  end
  let(:api_key) { project.uuid }

  before do
    request.headers['Api-Key'] = api_key
  end

  describe 'POST /init' do
    context 'when api key is wrong' do
      let(:api_key) { project.id }

      it 'returns Invalid Api-Key response' do
        post(:init, body: { s: 'http://localhost:3000/new-year-celebrations' })
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to eq "{\"message\":\"Invalid Api-Key\"}"
      end
    end

    it 'returns Incorrect domain response' do
      post(:init, body: { s: 'http://localhost:3000/new-year-celebrations' })
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to eq "{\"code\":\"wrong_domain\",\"message\":\"Incorrect domain\"}"
    end
    
    describe 'when http_status is 200' do
      render_views
      it 'returns response successfully' do
        project.update_attribute!(:domain, 'localhost')
        request.headers['origin'] = 'http://localhost'

        stub_request(:get, 'http://localhost:3000/new-year-celebrations').to_return(
        body: Rails.root.join('spec/fixtures/html/new-year-celebrations.html').read,
        headers: { 'Content-Type' => 'text/html' }
        )

        post(:init, body: { s: 'http://localhost:3000/new-year-celebrations' }.to_json, as: :json)
        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        # expect(body['article']).to have_key(:id)
        expect(body['article']['id']).to be_a(String)
        expect(body['article']['title']).to eq 'New Year celebrations'
        expect(body['settings']).to be_a(Hash)
      end
    end
  end
end
