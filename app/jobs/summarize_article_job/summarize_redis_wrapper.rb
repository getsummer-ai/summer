# frozen_string_literal: true
class SummarizeArticleJob
  class SummarizeRedisWrapper
    # @param [ProjectArticle] model
    # @param [Redis] redis_instance
    def initialize(model, redis_instance)
      @model = model
      @channel_name = model.redis_name
      @redis = redis_instance
    end

    def stream_function
      @stream_function ||= proc do |chunk, _bytesize|
        content = chunk.dig('choices', 0, 'delta', 'content')
        # Rails.logger.debug content
        @redis.append(@channel_name, content)
        @redis.publish(@channel_name, content)
      end
    end

    def result
      @redis.get(@channel_name)
    end

    def quit
      @redis&.publish(@channel_name, 'done')
      @redis&.del(@channel_name)
      @redis&.quit
    end
  end
end
