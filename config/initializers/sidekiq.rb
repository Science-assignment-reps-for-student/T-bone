Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{ENV['SCARFS_DB']}:6379/1" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{ENV['SCARFS_DB']}:6379/1" }
end

Sidekiq.default_worker_options = { retry: 1 }
