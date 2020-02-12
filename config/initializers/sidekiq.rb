Sidekiq.configure_server do |config|
  config.redis = { url: Rails.configuration.x.redis.url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.configuration.x.redis.url }
end

Sidekiq.default_worker_options = {retry: 1}
