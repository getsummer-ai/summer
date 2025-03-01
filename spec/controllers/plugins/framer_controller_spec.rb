# frozen_string_literal: true
RSpec.describe Plugins::FramerController do
  let(:user) { create_default_user }

  describe 'GET /login' do
    let(:session_id) { '550e8400-e29b-41d4-a716-446655440000' }
    let(:info_base64) { Base64.encode64({ project_id: 333, production: true, staging: false }.to_json) }
    let(:params) { { session_id:, info: info_base64 } }

    before { login_user(user) }

    context 'when params are correct' do
      it 'creates a project api key and redirects the user to the login page.' do
        expect(controller.current_user).not_to be_nil
        get :login, params: params
        api_key = ProjectApiKey.last
        expect(api_key).to have_attributes(
          key_type: 'framer',
          details: { project_id: 333, production: true, staging: false }.stringify_keys,
          usage_count: 0,
        )
        expect(response).to redirect_to new_user_session_path(framer_session_id: api_key.id)
        expect(controller.current_user).to be_nil
      end

      it 'finds created project api key and redirects the user to the login page.' do
        api_key = ProjectApiKey.create!(
          id: session_id,
          key_type: 'framer',
          details: { project_id: 333, production: true, staging: false },
        )
        get :login, params: params
        expect(response).to redirect_to new_user_session_path(framer_session_id: api_key.id)
        expect(controller.current_user).to be_nil
      end

      it 'can\'t find a created project api key and creates another one' do
        ProjectApiKey.create!(id: session_id, key_type: 'default')
        get :login, params: params
        expect(response).to have_http_status :forbidden
      end
    end

    context 'when params are incorrect' do
      let(:params) { { session_id: 'asdfasdf', info: info_base64 } }

      it 'returns an error' do
        get :login, params: params
        expect(response).to have_http_status :bad_request
        expect(controller.current_user).not_to be_nil
      end
    end
  end
end
