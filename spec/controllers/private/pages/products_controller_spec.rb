# frozen_string_literal: true
RSpec.describe Private::Pages::ProductsController do
  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
  let!(:user) { create_default_user }
  let!(:project) { create_default_project_for(user) }
  let!(:article) { project.articles.create!(article_hash: '354', article: 'On the...') }
  let(:page) { project.pages.create!(url: 'http://localhost:3000/random', url_hash: 'r', article:) }

  before { login_user(user) }

  describe 'GET /new' do
    it 'shows a modal view when request is a turbo request' do
      request.headers['Turbo-Frame'] = '123'
      get :new, params: { project_id: project.to_param, page_id: page.to_param }
      expect(response).to have_http_status(:ok).and render_template(:new)
    end

    it 'redirects to turbo view when request is not a turbo request' do
      get :new, params: { project_id: project.to_param, page_id: page.to_param }
      expect(response).to redirect_to(
        project_page_path(anchor: PrivateController.generate_modal_anchor(new_project_page_product_path))
      )
    end
  end

  describe 'GET /edit' do
    let(:product) { project.products.create!(name: 'A', link: 'http://a.com', description: 'Op') }
    let(:article_product) { article.project_article_products.create!(product:) }

    it 'sends turbo frame response shows when request is a turbo request' do
      request.headers['Turbo-Frame'] = '123'
      get :edit, params: { project_id: project.to_param, page_id: page.to_param, id: article_product.to_param }
      expect(response).to have_http_status(:ok).and render_template(:edit)
    end

    it 'redirects when request is not a turbo request' do
      get :edit, params: { project_id: project.to_param, page_id: page.to_param, id: article_product.to_param }
      expect(response).to redirect_to(
        project_page_path(anchor: PrivateController.generate_modal_anchor(edit_project_page_product_path))
      )
    end
  end

  describe 'POST /destroy' do
    let(:product) { project.products.create!(name: 'A', link: 'http://a.com', description: 'Op') }
    let(:article_product) { article.project_article_products.create!(product:) }

    it 'redirects after detaching' do
      delete :destroy, params: { project_id: project.to_param, page_id: page.to_param, id: article_product.to_param }
      expect(response).to redirect_to(project_page_path)
      expect(flash[:notice]).to match(/.* was detached/)
    end
  end

  describe 'POST /create' do
    let(:product) { project.products.create!(name: 'A', link: 'http://a.com', description: 'Op') }
    let(:params) do
      {
        project_id: project.to_param,
        page_id: page.to_param,
        project_article_product: { project_product_id: product.id }
      }
    end

    it 'redirects after attaching' do
      expect { post(:create, params:) }.to change(ProjectArticleProduct, :count).by(1)
      expect(response).to redirect_to(project_page_path)
      expect(flash[:notice]).to eq('The product was successfully attached')
    end

    context 'when product is not found' do
      it 'returns unprocessable_entity and renders new template' do
        params[:project_article_product][:project_product_id] = 0
        post(:create, params:)
        expect(response).to have_http_status(:unprocessable_entity).and render_template(:new)
      end
    end

    context 'when project_product_id relates to another project' do
      it 'returns unprocessable_entity and renders new template' do
        another_project = user.projects.create!(protocol: 'https', domain: 'localhost.io', name: 'TeProject')
        another_article = another_project.articles.create!(article_hash: '354', article: 'On the...')
        another_page = another_project.pages.create!(
          url: 'https://localhost.io/random',
          url_hash: 'r',
          article: another_article
        )

        params[:project_id] = another_project.to_param
        params[:page_id] = another_page.to_param
        post(:create, params:)
        expect(response).to have_http_status(:unprocessable_entity).and render_template(:new)
      end
    end
  end

  describe 'POST /update' do
    let(:product) { project.products.create!(name: 'A', link: 'http://a.com', description: 'Op') }
    let(:product_2) { project.products.create!(name: 'N', link: 'http://n.com', description: 'Op') }
    let(:article_product) { article.project_article_products.create!(product:, position: 1) }
    let(:params) do
      {
        project_id: project.to_param,
        page_id: page.to_param,
        id: article_product.to_param,
        project_article_product: { project_product_id: product_2.id, is_accessible: false, position: 10 }
      }
    end

    it 'redirects after disabling' do
      expect { patch :update, params: }.to \
        change { article_product.reload.product }.from(product).to(product_2).and \
        change { article_product.reload.position }.from(1).to(10)
      expect(response).to redirect_to(project_page_path)
      expect(flash[:notice]).to eq("\"N\" product is disabled")
    end
  end
end
