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
        SummarizeArticleJob.perform_later(article.id) if article.status_in_queue?
        response.headers['Content-Type'] = 'text/event-stream'
        sse = SSE.new(response.stream)
        return sse.write(article.summary) if article.status_summarized?

        subscribe_and_send_stream(sse, article.redis_name)
      ensure
        sse&.close
        @redis&.quit
      end

      private

      # @return [ProjectArticle]
      def article
        @article ||=
          current_project
            .project_articles
            .where(status: %i[in_queue processing summarized])
            .summary_columns
            .find(@article_id)
      end

      #   @param [SSE] sse
      #   @param [String] channel_name
      def subscribe_and_send_stream(sse, channel_name)
        # on first message from redis we send the buffered summary
        message = 0
        init_message = redis.get(channel_name)
        redis.subscribe_with_timeout(10, channel_name) do |on|
          on.message do |_event, data|
            if data == 'done'
              redis.unsubscribe(channel_name)
            elsif message.zero? && init_message.present?
              sse.write init_message
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

      def redis
        @redis ||= Redis.new
      end
    end
  end
end
