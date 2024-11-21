# frozen_string_literal: true
module Api
  module V1
    module Pages
      #
      # Controller with basic logic for getting article summary
      #
      class ProductsController < DefaultController
        before_action { |_| authorize current_project, :use_suggestion_feature? }

        def show
          # @type [ProjectArticle]
          article =
            ProjectArticle.only_required_columns.find_by(id: project_page.project_article_id)

          if article.products_status_completed?
            @products = find_products_for project_page
            mark_as_viewed(@products) and return
          end

          if article.products_status_error? || !current_project.products.exists?
            return(@products = [])
          end

          FindProductsInSummaryJob.perform_later(article.id) if article.products_status_wait?
          @products = wait_on_redis_channel(article) ? find_products_for(project_page) : []
        end

        def click
          product = @current_project.products.select('id').find_by(uuid: params[:uuid])
          if product.present?
            StatisticService.new(project: @current_project, trackable: product).click!
          end
          head :ok
        end

        private

        # @param [ProjectArticle] article
        # @return [Boolean]
        def wait_on_redis_channel(article)
          channel_name = article.redis_products_name
          redis = RedisFactory.new
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
          ids_query =
            ProjectArticleProduct.select('project_product_id').active.where(project_article_id:)
          @current_project.products.where(id: ids_query).only_main_columns.icon_as_base64.to_a
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
