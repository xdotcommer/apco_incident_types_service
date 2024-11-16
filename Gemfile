source "https://rubygems.org"
gem "rails", "~> 8.0.0"
gem "redis", ">= 4.0.1"
gem "puma"


gem "bootsnap", require: false
gem "kamal", require: false
gem "csv"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop", require: false
  gem "rspec-rails", "~> 7.1"  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end
