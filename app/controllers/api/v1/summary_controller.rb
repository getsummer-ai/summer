# frozen_string_literal: true
module Api
  module V1
    #
    # Controller with basic logic for getting article summary
    #
    class SummaryController < Api::V1::ApplicationController
      include ActionController::Live
      before_action :extract_data_from_id_param
      after_action :update_statistics

      wrap_parameters false

      def stream
        SummarizeArticleJob.perform_later(article.id) if article.status_summary_wait?
        response.headers['Content-Type'] = 'text/event-stream'
        sse = SSE.new(response.stream)
        return sse.write(article.project_article_summaries.last.summary) if article.status_summary_completed?

        subscribe_and_send_from_stream(sse, article)
      ensure
        sse&.close
      end

      private

      # @return [ProjectArticle]
      def article
        @article ||=
          current_project
            .project_articles
            .where(status_summary: %i[wait processing completed])
            .only_required_columns
            .find(@article_id)
      end

      #   @param [SSE] sse
      #   @param [ProjectArticle] article
      def subscribe_and_send_from_stream(sse, article)
        # on first message from redis we send the buffered summary
        channel_name = article.redis_name
        redis_subscriber = Redis.new
        redis_buffer = Redis.new
        subscribe_on_channel(sse, redis_subscriber, redis_buffer, channel_name)
      rescue Redis::TimeoutError => e
        sse.write(article.summary) if article.reload.status_summary
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

      def update_statistics
        return if @url_id.nil? || @article.nil?

        service = ArticleStatisticService.new(url_id: @url_id, article_id: @article.id)
        service.click!
      end

      def extract_data_from_id_param
        decoded_info = BasicEncrypting.decode_array(params.permit(:id)[:id], 3)
        return head(:bad_request) if decoded_info.nil?

        expired_at = decoded_info[2]
        return head(:gone) if Time.now.utc.to_i > expired_at

        @article_id = decoded_info[0]
        @url_id = decoded_info[1]
      end
    end
  end
end
