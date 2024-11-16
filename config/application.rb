require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module ApcoIncidentTypes
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.api_only = true
    config.active_support.remove_deprecated_time_with_zone_name = true
    config.active_support.cache_format_version = 7.0
    config.autoloader = :zeitwerk
    config.cache_store = :redis_cache_store, {
       url: ENV.fetch("REDIS_URL", "redis://localhost:6380/1")
    }
    config.hosts << "apco_service"
  end
end
