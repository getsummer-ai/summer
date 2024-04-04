# frozen_string_literal: true
module Private
  class ProductsController < PrivateController
    include Pagy::Backend
    before_action :find_project
    before_action :set_product, only: %i[edit update destroy]

    layout :private_or_turbo_layout

    def new
      @project_product = ProjectProduct.new
      return if turbo_frame_request?
      modal_anchor_to_open = Base64.encode64(new_project_product_path(@current_project))
      # @type [ProjectPageDecorator]
      redirect_to knowledge_project_path(anchor: "m=#{modal_anchor_to_open}")
    end

    def edit
      return if turbo_frame_request?
      modal_anchor_to_open = Base64.encode64(project_product_path(@current_project, @project_product))
      # @type [ProjectPageDecorator]
      redirect_to knowledge_project_path(anchor: "m=#{modal_anchor_to_open}")
    end

    def create
      @project_product = ProjectProduct.new(product_params.merge(project: @current_project))
      return render(:new, status: :unprocessable_entity) unless @project_product.save

      flash[:notice] = 'Successfully created'
      respond_to do |format|
        format.html { redirect_to knowledge_project_path }
        format.turbo_stream { flash.now[:notice] = 'Successfully created' }
      end
    end

    def update
      @project_product.update product_params
      return render(:edit, status: :unprocessable_entity) if @project_product.errors.any?

      respond_to do |format|
        format.html { redirect_to knowledge_project_path, notice: 'Successfully updated' }
        format.turbo_stream do
          flash.now[:notice] = 'Successfully updated'
        end
      end
    end

    def destroy
      unless @project_product.destroy
        Rails.logger.error("Error: deleting service (#{@project_product.id}) from project #{@project.id} - " \
                           + @path_form.errors.full_messages.to_s)
        return redirect_to(knowledge_project_path, alert: 'Error happened while deleting the path')
      end

      respond_to do |format|
        format.html { redirect_to knowledge_project_path, notice: "#{@project_product.name} was deleted" }
        format.turbo_stream { flash.now[:notice] = "#{@project_product.name} was deleted" }
      end
    end

    private

    def set_product
      id = params[:id].is_a?(String) ? BasicEncrypting.decode(params[:id]) : params[:id]
      @project_product = @current_project.products.skip_retrieving(:icon).find(id)
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.fetch(:project_product, {}).permit(:name, :description, :link)
    end
  end
end
