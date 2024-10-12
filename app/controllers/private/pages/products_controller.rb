# frozen_string_literal: true
module Private
  module Pages
    class ProductsController < PrivateController
      include ProjectPageFinderConcern

      before_action :find_project
      before_action :find_project_page
      before_action :find_article_product, only: %i[update]

      layout :private_or_turbo_layout

      def new
        @article_product = ProjectArticleProduct.new
        return if turbo_frame_request?

        modal_anchor_to_open = Base64.encode64(new_project_page_product_path)
        # @type [ProjectPageDecorator]
        redirect_to project_pages_path(anchor: "m=#{modal_anchor_to_open}")
      end

      def create
        p = params.fetch(:project_article_product, {}).permit(:project_product_id)
        @article_product = ProjectArticleProduct.new(
          product: current_project.products.find_by(id: p[:project_product_id]),
          article: @project_page.article
        )
        return render(:new, status: :unprocessable_entity) unless @article_product.save

        notice = 'Successfully added'
        respond_to do |format|
          format.html { redirect_to project_pages_path, notice: }
          format.turbo_stream { flash.now[:notice] = notice }
        end
      end

      def update
        unless @article_product.update(article_product_params)
          return redirect_to project_pages_path, error: "Relevant product wasn't updated"
        end

        notice =
          "\"#{@article_product.product.name}\" product is " +
            (@article_product.is_accessible ? 'enabled' : 'disabled')
        respond_to do |format|
          format.html { redirect_back_or_to project_page_path, notice: }
          format.turbo_stream { flash.now[:notice] = notice }
        end
      end

      private

      def find_article_product
        # @type [ProjectArticleProduct]
        @article_product =
          @project_page.article.project_article_products.find(BasicEncrypting.decode(params[:id]))
      end

      def article_product_params
        params.fetch(:project_article_product, {}).permit(:is_accessible, :position)
      end
    end
  end
end
