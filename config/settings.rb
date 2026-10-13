# frozen_string_literal: true

module Shoebox
  class Settings < Hanami::Settings
    # Signs and encrypts the session cookie, and signs password reset tokens.
    setting :session_secret, constructor: Types::String.constrained(min_size: 64)

    # Define your app settings here, for example:
    #
    # setting :my_flag, default: false, constructor: Types::Params::Bool

    # File storage for attachments (hanami-attachments). See .env for the S3 settings.
    setting :storage_service, default: Hanami.env?(:production) ? "s3" : "file_system", constructor: Types::String
    setting :storage_bucket, default: nil, constructor: Types::String.optional
    setting :storage_region, default: nil, constructor: Types::String.optional
    setting :storage_endpoint, default: nil, constructor: Types::String.optional
    setting :storage_access_key_id, default: nil, constructor: Types::String.optional
    setting :storage_secret_access_key, default: nil, constructor: Types::String.optional
    setting :storage_public, default: false, constructor: Types::Params::Bool
    setting :storage_cdn_host, default: nil, constructor: Types::String.optional

    # Signs local file URLs (falls back to SESSION_SECRET).
    setting :storage_url_secret, default: nil, constructor: Types::String.optional
  end
end
