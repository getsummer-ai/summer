# frozen_string_literal: true
module Private
  module Pages
    class ProductsController < PrivateController
      include ProjectPageFinderConcern

      before_action :find_project
      before_action :find_project_page
      before_action :find_article_product, only: %i[update edit destroy]

      layout :private_or_turbo_layout

      def new
        @article_product = ProjectArticleProduct.new
        return if turbo_frame_request?

        redirect_to project_page_path(anchor: generate_modal_anchor(new_project_page_product_path))
      end

      def edit
        return if turbo_frame_request?

        redirect_to project_page_path(anchor: generate_modal_anchor(edit_project_page_product_path))
      end

      def create
        p = params.fetch(:project_article_product, {}).permit(:project_product_id)
        @article_product =
          ProjectArticleProduct.new(
            product: current_project.products.find_by(id: p[:project_product_id]),
            article: @project_page.article,
          )
        return render(:new, status: :unprocessable_entity) unless @article_product.save

        notice = 'The product was successfully attached'
        respond_to do |format|
          format.html { redirect_to project_page_path, notice: }
          format.turbo_stream { flash.now[:notice] = notice }
        end
      end

      def update
        product =
          if article_product_params[:project_product_id]
            current_project.products.find_by(id: article_product_params[:project_product_id])
          else
            @article_product.product
          end

        unless @article_product.update(article_product_params.merge(project_product_id: product&.id))
          return render(:new, status: :unprocessable_entity)
        end

        notice =
          "\"#{@article_product.product.name}\" product is " +
            (@article_product.is_accessible ? 'enabled' : 'disabled')
        respond_to do |format|
          format.html { redirect_to project_page_path, notice: }
          format.turbo_stream { flash.now[:notice] = notice }
        end
      end

      def destroy
        return redirect_to(project_page_path) unless @article_product.destroy

        notice = "\"#{@article_product.product.name}\" was detached"
        respond_to do |format|
          format.html { redirect_to project_page_path, notice: }
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
        params.fetch(:project_article_product, {}).permit(
          :project_product_id,
          :is_accessible,
          :position,
        )
      end
    end
  end
end
