# frozen_string_literal: true

RSpec.describe Private::ProjectUsersController, type: :controller do
  include SpecTestHelper

  let!(:user) { create_default_user(email: 'test@example.com') }
  let!(:project) do
    user.projects.create!(name: 'Test', protocol: 'https', domain: 'example.com', paths: [''])
  end
  let!(:project_user) { project.project_users.take }

  before { login_user(user) }

  describe 'GET #new' do
    it 'assigns a new ProjectUser and ProjectUserForm and returns response' do
      request.headers['Turbo-Frame'] = '123'
      get :new, params: { project_id: project.to_param }, session: {}
      expect(assigns(:project_user)).to be_a_new(ProjectUser)
      expect(assigns(:user_form)).to be_a(ProjectUserForm)
      expect(response).to have_http_status(:ok).and render_template(:new)
    end

    it 'redirects to project_settings_path unless turbo_frame_request?' do
      get :new, params: { project_id: project.to_param }
      expect(response).to have_http_status :found
      expect(response.location).to match("/projects/#{project.to_param}/settings#m=")
    end
  end

  describe 'GET #edit' do
    it 'redirects to project_settings_path unless turbo_frame_request?' do
      get :edit, params: { project_id: project.to_param, id: project_user.to_param }
      expect(response.location).to match("/projects/#{project.to_param}/settings#m=")
    end

    it 'assigns user_form if turbo_frame_request? and renders the edit template' do
      request.headers['Turbo-Frame'] = '123'
      get :edit, params: { project_id: project.encrypted_id, id: project_user.encrypted_id }
      expect(assigns(:user_form)).to be_a(ProjectUserForm)
      expect(response).to have_http_status(:ok).and render_template(:edit)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      { project_user_form: { email: 'new@example.com', role: 'viewer' }, project_id: project.to_param }
    end
    let(:invalid_params) do
      { project_user_form: { email: '', role: '' }, project_id: project.to_param }
    end

    it 'creates a new project user and redirects on success' do
      post :create, params: valid_params
      expect(response).to redirect_to(project_settings_path)
      expect(flash[:notice]).to be_present
    end

    it 'creates a new project user and renders turbo stream on success' do
      post :create, params: valid_params, as: :turbo_stream
      expect(response).to have_http_status(:ok).and render_template(:create)
      expect(flash[:notice]).to be_present
    end

    it 'renders new on failure if there is a html request' do
      post :create, params: invalid_params
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'renders new on failure if there is a turbo stream request' do
      post :create, params: invalid_params, as: :turbo_stream
      expect(response).to render_template(:new)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    let(:valid_params) do
      { project_user_form: { role: 'viewer' }, project_id: project.to_param, id: project_user.to_param }
    end
    let(:invalid_params) do
      { project_user_form: { role: '' }, project_id: project.to_param, id: project_user.to_param }
    end

    it 'updates the project user and redirects on success' do
      patch :update, params: valid_params
      expect(response).to redirect_to(project_settings_path)
      expect(flash[:notice]).to be_present
    end

    it 'updates the project user and renders turbo stream on success' do
      post :update, params: valid_params, as: :turbo_stream
      expect(response).to have_http_status(:ok).and render_template(:update)
      expect(flash[:notice]).to be_present
    end

    it 'renders edit on failure' do
      patch :update, params: invalid_params
      expect(response).to render_template(:edit)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'renders new on failure if there is a turbo stream request' do
      post :update, params: invalid_params, as: :turbo_stream
      expect(response).to render_template(:edit)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the project user and redirects' do
      delete :destroy, params: { project_id: project.to_param, id: project_user.to_param }
      expect(response).to redirect_to(project_settings_path)
      expect(flash[:notice]).to be_present
    end

    it 'logs error and sets notice if destroy fails' do
      allow_any_instance_of(ProjectUser).to receive(:destroy).and_return(false)
      allow_any_instance_of(ProjectUser).to receive_message_chain(:errors, :full_messages).and_return(['Error'])
      expect(Rails.logger).to receive(:error)
      delete :destroy, params: { project_id: project.to_param, id: project_user.to_param }
      expect(flash[:notice]).to eq('Error happened while deleting the path')
    end
  end

  describe 'POST #send_notification_email' do
    it 'sends invitation if not sent recently' do
      allow_any_instance_of(ProjectUser).to receive(:invitation_sent_at).and_return(nil)
      expect_any_instance_of(ProjectUser).to receive(:send_invitation)
      post :send_notification_email, params: { project_id: project.to_param, id: project_user.to_param }
      expect(flash[:alert]).to eq('Invitation email was sent')
    end

    it 'does not send invitation if sent recently' do
      allow_any_instance_of(ProjectUser).to receive(:invitation_sent_at).and_return(10.minutes.ago)
      expect_any_instance_of(ProjectUser).not_to receive(:send_invitation)
      post :send_notification_email, params: { project_id: project.to_param, id: project_user.to_param }
      expect(flash[:alert]).to eq('Invitation email was sent recently. Please try again later.')
    end
  end
end
