# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.1.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"
# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem 'kamal', require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem 'bundler-audit', require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false
  gem 'test-prof', '~> 1.4'
  gem 'bullet', '~> 8.1'
  gem 'factory_bot_rails', '~> 6.5'
  gem 'ffaker', '~> 2.25'
  gem 'pry-rails', '~> 0.3.11'
end

group :test do
  gem 'shoulda-matchers', '~> 6.0'
end

group :development do
  gem 'annotaterb', '~> 4.20'
  gem 'database_consistency', require: false
  gem 'dotenv-rails', '~> 3.1'
  gem 'isolator', '~> 1.2'
  gem 'rspec-rails', '~> 8.0'
  gem 'rubocop-factory_bot', '~> 2.28', require: false
  gem 'rubocop-performance', '~> 1.26', require: false
  gem 'rubocop-rails', '~> 2.33', require: false
  gem 'rubocop-rails-omakase', require: false
  gem 'rubocop-rspec', '~> 3.8'
  gem 'rubocop-rspec_rails', '~> 2.32'
  gem 'ruby-lsp', '~> 0.26.3', require: false
  gem 'ruby-lsp-factory_bot', '~> 0.6.0', require: false
  gem 'ruby-lsp-rails', '~> 0.4.8', require: false
  gem 'ruby-lsp-rspec', '~> 0.1.28', require: false
end

gem 'jwt', '~> 3.1'

gem 'strong_migrations', '~> 2.5'

gem 'rswag', '~> 2.17'

gem 'lograge', '~> 0.14.0'

gem 'amazing_print', '~> 2.0'

gem 'data_migrate', '~> 11.3'
