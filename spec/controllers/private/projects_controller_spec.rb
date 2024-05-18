# frozen_string_literal: true
RSpec.describe Private::ProjectsController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let!(:user) { create_default_user }

  before { login_user(user) }

  describe 'GET /new' do
    context 'when request is a turbo request' do
      before { request.headers['Turbo-Frame'] = '123' }

      it 'shows modal view if there is a project already' do
        user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
        get :new
        expect(response).to have_http_status :ok
      end

      it 'shows modal view user does not have a project' do
        request.headers['Turbo-Frame'] = '123'
        get :new
        expect(response).to have_http_status :ok
      end
    end

    context 'when request is not a turbo request' do
      it 'shows a page when user does not have a project' do
        get :new
        expect(response).to have_http_status :ok
      end

      it 'redirects to turbo view if user has a project already' do
        user.projects.create!(protocol: 'http', domain: 'localhost.com', name: 'Test Project')
        get :new
        path_to =
          billing_index_path(anchor: PrivateController.generate_modal_anchor(new_project_path))
        expect(response).to redirect_to(path_to)
      end
    end
  end
end
