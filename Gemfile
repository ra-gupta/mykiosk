source "https://rubygems.org"

gem "rails", "~> 8.0.5", ">= 8.0.5.1"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"

gem "propshaft"
gem "tailwindcss-rails", "~> 4.6"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"

gem "bcrypt", "~> 3.1.7"

# Database-backed adapters for Rails.cache, Active Job and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
