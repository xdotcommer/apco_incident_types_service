require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include Rails.application.routes.url_helpers
end

# spec/rails_helper.rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'

# Helper module to stub Redis operations
module RedisStubHelper
  def stub_redis_connection
    redis_double = double('Redis')
    allow(redis_double).to receive(:flushdb).and_return("OK")
    allow(redis_double).to receive(:set).and_return("OK")
    allow(redis_double).to receive(:get).and_return(nil)
    allow(redis_double).to receive(:keys).and_return([])
    allow(redis_double).to receive(:del).and_return(1)
    redis_double
  end

  def stub_redis_pool
    redis_double = stub_redis_connection
    pool_double = double('ConnectionPool')
    allow(pool_double).to receive(:with).and_yield(redis_double)
    allow(ConnectionPool::Wrapper).to receive(:new).and_return(pool_double)
    redis_double
  end
end

RSpec.configure do |config|
  config.include RedisStubHelper

  config.before(:suite) do
    # No need to check Redis connection
  end

  config.before(:each) do
    # Stub Redis by default
    stub_redis_pool
  end
end
