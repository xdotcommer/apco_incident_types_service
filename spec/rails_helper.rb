require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rspec/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include Rails.application.routes.url_helpers

  config.before(:suite) do
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  config.before(:each) do
    Rails.cache.clear
  end
end
