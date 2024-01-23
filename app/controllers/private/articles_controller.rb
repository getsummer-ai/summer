# frozen_string_literal: true
module Private
  class ArticlesController < PrivateController
    before_action :set_project, only: %i[index show edit update]
    before_action :set_article, only: %i[show edit update]

    layout :custom_layout

    def custom_layout
      return 'turbo_rails/frame' if turbo_frame_request?
      'private'
    end

    # GET /projects or /projects.json
    def index
      # return redirect_to project_url(@project) unless turbo_frame_request?
      @articles = @project.project_articles.all
    end

    def show
    end

    def edit
    end

    def update
      respond_to do |format|
        if @article.update(article_params)
          format.html do
            redirect_to project_article_url(@project, @article),
                        notice: 'Article was successfully updated.'
          end
          format.json { render :show, status: :ok, location: @project }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      end
    end

    private

    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_article
      # @article = @project.project_articles.find(params[:id])
      @article =
        @project.project_articles.first_or_create do |article|
          article.title = 'Article Title'
          article.summary = 'Article Summary'
          article.article = 'Article Content'
          article.article_hash = 'Article Content'
          article.is_summarized = true
        end
    end

    # Only allow a list of trusted parameters through.
    def article_params
      params.fetch(:project_article, {}).permit(:article, :title, :summary)
    end
  end
end
