require 'redis'

class RedisMock
  def initialize
    @redis = Redis.new
  end

  def with_redis(&block)
    begin
      @redis_host = ENV.fetch('REDIS_HOST', 'localhost')
      @redis_port = ENV.fetch('REDIS_PORT', 6379)
      @redis = Redis.new(host: @redis_host, port: @redis_port)
      block.call(@redis)
    ensure
      @redis.quit
    end
  end
end

RSpec.configure do |config|
  config.before(:each) do
    redis_mock = RedisMock.new
    allow(Redis).to receive(:new).and_return(redis_mock)
    allow_any_instance_of(Redis).to receive(:with).and_wrap_original { |m, *args| redis_mock.with_redis(&m.method(:call).to_proc) }
  end
end
