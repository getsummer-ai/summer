# frozen_string_literal: true
module Api
  module V1
    module Pages
      #
      # Controller with basic logic for getting article summary
      #
      class ProductsController < DefaultController
        def show
          # @type [ProjectArticle]
          article = ProjectArticle.only_required_columns.find_by(id: project_page.project_article_id)
          if !current_project.products.exists? || article.products_status_error?
            return (@products = [])
          end

          if article.products_status_completed?
            @products = find_products_for project_page
            mark_as_viewed(@products) and return
          end

          FindProductsInSummaryJob.perform_later(article.id) if article.products_status_wait?
          @products = wait_on_redis_channel(article) ? find_products_for(project_page) : []
        end

        def click
          service = @current_project.services.select('id').find_by!(uuid: params[:uuid])
          StatisticService.new(project: @current_project, trackable: service).click!
          head :ok
        end

        private

        # @param [ProjectArticle] article
        # @return [Boolean]
        def wait_on_redis_channel(article)
          channel_name = article.redis_products_name
          redis = Redis.new
          begin
            redis.subscribe_with_timeout(5, channel_name) do |on|
              on.message { |_event, data| redis.unsubscribe(channel_name) if data == 'done' }
            end
          rescue Redis::TimeoutError => e
            Rails.logger.error e.message
            return false
          ensure
            redis.quit
          end
          true
        end

        #  @param [ProjectPage] project_page
        #  @return [Array<ProjectProducts>]
        def find_products_for(project_page)
          project_article_id = project_page.project_article_id
          @current_project
            .products
            .where(id: ProjectArticleProduct.select('project_product_id').where(project_article_id:))
            .only_main_columns
            .icon_as_base64
            .to_a
        end

        def mark_as_viewed(services)
          services.each do |service|
            StatisticService.new(project: @current_project, trackable: service).view!
          end
        end
      end
    end
  end
end
