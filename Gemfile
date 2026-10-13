# frozen_string_literal: true

source "https://rubygems.org"

gem "hanami", github: "hanami/hanami", branch: "main"
gem "hanami-cli", github: "hanami/hanami-cli", branch: "main"
gem "hanami-utils", github: "hanami/hanami-utils", branch: "main"
gem "hanami-assets", github: "hanami/hanami-assets", branch: "main"
gem "hanami-action", github: "hanami/hanami-action", branch: "main"
gem "hanami-db", github: "hanami/hanami-db", branch: "main"
gem "hanami-mailer", github: "hanami/hanami-mailer", branch: "main"
gem "hanami-router", github: "hanami/hanami-router", branch: "main"
gem "hanami-view", github: "hanami/hanami-view", branch: "main"

# Hanami main depends on unreleased dry-rb changes (hanami-cli main needs dry-cli's Dry CLI 2 API).
gem "dry-cli", github: "dry-rb/dry-cli", branch: "main"
gem "dry-system", github: "dry-rb/dry-system", branch: "main"

gem "dry-types", "~> 1.7"
gem "dry-operation", ">= 1.0.1"
gem "dry-validation", "~> 1.11"
gem "i18n", "~> 1.14"
gem "puma", ">= 7.1"
gem "rake"
gem "sqlite3"

gem "hanami-turbo", "~> 0.1"

# File attachments. In the :cli group too, so `hanami generate storage` and `attachment` exist.
gem "hanami-attachments", path: "../hanami-attachments", group: [:default, :cli]

gem "argon2", "~> 2.3"

gem "aws-sdk-s3", "~> 1.0"

group :development do
  gem "hanami-webconsole", github: "hanami/hanami-webconsole", branch: "main"
end

group :development, :test do
  gem "dotenv"
  # Syntax highlighting SQL logs
  gem "rouge"
end

group :cli, :development do
  gem "hanami-auth", path: "../hanami-auth"
  gem "hanami-reloader", github: "hanami/hanami-reloader", branch: "main"
end

group :cli, :development, :test do
  gem "hanami-rspec", github: "hanami/hanami-rspec", branch: "main"
end

group :test do
  # Database
  gem "database_cleaner-sequel"

  # Web integration
  gem "capybara"
  gem "rack-test"
end
