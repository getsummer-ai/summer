# frozen_string_literal: true
RSpec.describe Plugins::FramerController do
  let(:user) { create_default_user }
  let(:session_id) { '550e8400-e29b-41d4-a716-446655440000' }

  describe 'GET /login' do
    let(:info_base64) do
      Base64.encode64({ project_id: 333, production: true, staging: false }.to_json)
    end
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
        api_key =
          ProjectApiKey.create!(
            id: session_id,
            key_type: 'framer',
            details: {
              project_id: 333,
              production: true,
              staging: false,
            },
          )
        get :login, params: params
        expect(response).to redirect_to new_user_session_path(framer_session_id: api_key.id)
        expect(controller.current_user).to be_nil
      end

      it 'can not find a project API key with default key type' do
        ProjectApiKey.create!(id: session_id, key_type: 'default')
        get :login, params: params
        expect(response).to have_http_status :not_found
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

  describe 'GET /success' do
    let(:params) { { session_id: } }
    let!(:api_key) { ProjectApiKey.create!(id: session_id, key_type: 'framer', details: {}) }

    it 'throws an error if user is not logged in' do
      get :success, params: params
      expect(response).to redirect_to new_user_session_path
    end

    context 'when user is logged in' do
      before { login_user(user) }

      it 'updates the project api key if session matches' do
        session[:framer_session_id] = session_id
        get :success, params: params
        api_key.reload
        expect(api_key).to have_attributes(
          activated_at: be_within(1.second).of(Time.now.utc),
          owner_id: user.id,
          project_id: nil,
          expired_at: be_within(1.second).of(6.months.from_now),
        )
      end

      it 'returns 404 if framer_session_id does not match session_id param' do
        session[:framer_session_id] = '123'
        get :success, params: params
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'POST /create_project' do
    let!(:api_key) do
      ProjectApiKey.create!(
        id: session_id,
        key_type: 'framer',
        expired_at: Time.now.utc + 1.minute,
        details: {
          name: 'Test',
          domain: 'test.com',
          domain_alis: 'test.com',
        },
      )
    end

    it 'creates a new project and attaches the project to a project api key' do
      login_user(user)
      session[:framer_session_id] = session_id

      expect(Project::CreateNewService).to receive(:new).with(
        user,
        name: 'Test',
        domain: 'test.com',
        domain_alis: 'test.com',
      ).and_call_original
      post :create_project, params: { session_id: session_id }

      expect(response).to have_http_status :found
      expect(response).to redirect_to success_plugins_framer_path(session_id: session_id)
      expect(flash[:notice]).to eq 'Project was successfully created.'
      project = Project.take
      expect(project).to have_attributes(name: 'Test', protocol: 'https', domain: 'test.com')
      expect(api_key.reload.project_id).to eq Project.last.id
    end

    it 'redirects to login page if user is not logged in' do
      post :create_project, params: { session_id: session_id }
      expect(response).to redirect_to new_user_session_path
    end

    it 'sets flash message if project creation fails' do
      login_user(user)
      session[:framer_session_id] = session_id

      api_key.update! details: { name: 'Test',  domain: 'test', domain_alis: 'test' }
      post :create_project, params: { session_id: session_id }
      expect(flash[:notice]).to eq 'Domain must be a valid url'
      expect(response).to redirect_to success_plugins_framer_path(session_id: session_id)
    end
  end

  describe 'PUT /select_project' do
    let!(:api_key) do
      ProjectApiKey.create!(
        id: session_id,
        key_type: 'framer',
        expired_at: Time.now.utc + 1.minute,
        details: {
          name: 'Test',
          domain: 'test.com',
          domain_alis: 'test.com',
        },
      )
    end
    let!(:project) { create_default_project_for(user) }

    it 'attaches an existing project to a project api key' do
      login_user(user)
      session[:framer_session_id] = session_id

      put :select_project, params: { session_id: session_id, project_id: project.uuid }

      expect(response).to have_http_status :found
      expect(response).to redirect_to success_plugins_framer_path(session_id: session_id)
      expect(flash[:notice]).to eq "Project #{project.name} has been selected."
      expect(api_key.reload.project_id).to eq project.id
    end

    it 'redirects to login page if user is not logged in' do
      post :create_project, params: { session_id: session_id }
      expect(response).to redirect_to new_user_session_path
    end
  end
end
