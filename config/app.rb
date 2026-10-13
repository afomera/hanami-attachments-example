# frozen_string_literal: true

require "hanami"
require "hanami/turbo"

module Shoebox
  class App < Hanami::App
    config.actions.sessions = :cookie, {
      key: "shoebox.session",
      secret: settings.session_secret,
      expire_after: 60 * 60 * 24 * 30, # 30 days
      same_site: "Lax",
      httponly: true,
      secure: Hanami.env?(:production)
    }
  end
end
