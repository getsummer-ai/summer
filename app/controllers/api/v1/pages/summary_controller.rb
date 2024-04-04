# frozen_string_literal: true
module Api
  module V1
    module Pages
      #
      # Controller with basic logic for getting article summary
      #
      class SummaryController < DefaultController
        include ActionController::Live

        def stream
          article = ProjectArticle.only_required_columns.find(project_page.project_article_id)
          SummarizeArticleJob.perform_later(article.id) if article.summary_status_wait?
          response.headers['Content-Type'] = 'text/event-stream'
          sse = SSE.new(response.stream)
          send_article(sse, article)
          StatisticService.new(project: @current_project, trackable: @project_page).click!
        rescue StandardError => e
          sse&.write('--ERROR--')
          Rails.logger.error e.message
        ensure
          sse&.close
        end

        private

        #   @param [SSE] sse
        #   @param [ProjectArticle] article
        def send_article(sse, article)
          return sse.write(article.summary_llm_call.output) if article.summary_status_completed?

          subscribe_and_send_from_stream(sse, article)
        end

        #   @param [SSE] sse
        #   @param [ProjectArticle] article
        def subscribe_and_send_from_stream(sse, article)
          # on first message from redis we send the buffered summary
          channel_name = article.redis_summary_name
          redis_subscriber = Redis.new
          redis_buffer = Redis.new
          subscribe_on_channel(sse, redis_subscriber, redis_buffer, channel_name)
        rescue Redis::TimeoutError => e
          sse.write(article.summary_llm_call.output) if article.reload.summary_status_completed?
          Rails.logger.error e.message
          raise
        ensure
          redis_subscriber&.quit
          redis_buffer&.quit
        end

        #   @param [SSE] sse
        #   @param [Redis] redis_subscriber
        #   @param [Redis] redis_buffer
        #   @param [String] channel_name
        def subscribe_on_channel(sse, redis_subscriber, redis_buffer, channel_name)
          message = 0
          redis_subscriber.subscribe_with_timeout(5, channel_name) do |on|
            on.message do |_event, data|
              if message.zero? && redis_buffer.exists?(channel_name)
                sse.write redis_buffer.get(channel_name)
              elsif data == 'done'
                redis_subscriber.unsubscribe(channel_name)
              else
                sse.write data
              end
              message += 1
            end
          end
        end
      end
    end
  end
end
