# frozen_string_literal: true

describe 'Test Redis accessibility and test pub/sub' do
  let(:queue) { Queue.new }

  around do |ex|
    # require 'fakeredis/rspec'
    FakeRedis.disable
    ex.run
    FakeRedis.enable
  end

  it 'receives a published message' do
    message = nil

    thread =
      Thread.new do
        RedisFactory
          .new
          .subscribe('channel1') do |on|
            on.message do |_channel, m|
              message = m
              Thread.current.kill
            end
          end
      end

    Timeout.timeout(1) do
      sleep 0.1
      expect(message).to be_nil
      RedisFactory.new.publish('channel1', 'Hello, world!')
      loop { break if thread.status == false }
      expect(message).to eq('Hello, world!')
      thread.kill
    end
  end
end
