source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2'

# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5.3'

# Use Unicorn as the app server
gem 'unicorn'
gem 'unicorn-rails'

# Use to send mails
gem 'mailgun-ruby'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'

# Use Redis adapter to run Action Cable in production
gem 'connection_pool'
gem 'redis', '~> 4.0'
gem 'redis-objects'
gem 'sidekiq', '~> 5.0'

# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.4.6', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

# Use JWT auth
gem 'jwt'
gem 'jwt_extended', '~> 0.0.2'

# Use spreadsheet gem for excel
gem 'spreadsheet'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '~> 3.1.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
