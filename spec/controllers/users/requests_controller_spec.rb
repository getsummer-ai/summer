# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::RequestsController do
  render_views

  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let(:user) do
    User.create(
      email: 'admin@test.ru',
      password: '12345678',
      password_confirmation: '12345678',
      confirmed_at: Time.zone.now,
    )
  end

  let(:filepath) { Rails.root.join('spec/fixtures/files/1kb.png') }

  before { login_user(user) }

  after { user.user_requests.each { |r| r.input_image.purge } }

  describe 'GET /index' do
    it 'fails because it is not routed' do
      expect { get(:index) }.to raise_error(ActionController::UrlGenerationError)
    end
  end

  describe 'GET /show' do
    let!(:user_request) do
      request_form =
        CreateRequestForm.new(
          user,
          { type: 'focus_restoration', image: fixture_file_upload(filepath, 'image/png') },
        ).submit
      request_form
    end

    it 'renders a successful response' do
      get :show, params: { id: user_request.id }
      expect(response).to be_successful
      expect(response.body).to eq(
        {
          request: {
            id: user_request.id,
            type: user_request.type,
            status: user_request.status,
            created_at: user_request.created_at,
            finished_at: user_request.finished_at,
          },
        }.to_json,
      )
    end

    it 'fails as there is no request' do
      expect { get :show, params: { id: -1 } }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      let(:valid_attrs) do
        { type: 'focus_restoration', image: fixture_file_upload(filepath, 'image/png') }
      end

      it 'creates a new request' do
        params = { request_form: valid_attrs }
        expect { post(:create, params:) }.to change(UserRequest, :count).by(1)
        user_request = UserRequest.last
        expect(response.body).to eq(
          {
            success: true,
            request: {
              id: user_request.id,
              type: user_request.type,
              status: user_request.status,
              created_at: user_request.created_at,
              finished_at: user_request.finished_at,
            },
          }.to_json,
        )
      end

      # it "redirects to the created post" do
      #   post :create, params: { post: valid_attributes }
      #   expect(response).to redirect_to(post_url(Post.last))
      # end
    end

    context 'with invalid parameters' do
      let(:invalid_attrs) do
        { type: 'focus_0000', image: fixture_file_upload(filepath, 'image/png') }
      end

      it 'renders a response with 422 status' do
        post :create, params: { request_form: invalid_attrs }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to eq(
          { success: false, errors: ['Type is not included in the list'] }.to_json,
        )
      end
    end
  end
end
