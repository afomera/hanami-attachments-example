# frozen_string_literal: true

module Shoebox
  class Settings < Hanami::Settings
    # Signs and encrypts the session cookie, and signs password reset tokens.
    setting :session_secret, constructor: Types::String.constrained(min_size: 64)

    # Define your app settings here, for example:
    #
    # setting :my_flag, default: false, constructor: Types::Params::Bool
  end
end
