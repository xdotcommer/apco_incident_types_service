# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  config.use_active_record = false
  config.enable_reloading = false
  config.eager_load = ENV["CI"].present?
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  config.consider_all_requests_local = true
  config.cache_store = :null_store

  config.action_dispatch.show_exceptions = :rescuable
  config.action_controller.allow_forgery_protection = false
  config.active_support.deprecation = :stderr
  config.hosts.clear

  config.action_controller.raise_on_missing_callback_actions = true
  config.cache_store = :redis_cache_store, {
    driver: :ruby,
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
    namespace: "apco_incident_types:test",
    connect_timeout: 30,
    read_timeout: 0.2,
    write_timeout: 0.2,
    reconnect_attempts: 1,
    error_handler: ->(method:, returning:, exception:) {
      Rails.logger.error "Redis error: #{exception.class} - #{exception.message}"
      Rails.logger.error exception.backtrace.join("\n")
    }
  }
end
