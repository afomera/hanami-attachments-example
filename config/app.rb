# frozen_string_literal: true

require "hanami"
require "hanami/turbo"
require "hanami/attachments"

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

    # Uploaders are classes, not components (hanami-attachments).
    config.no_auto_register_paths += ["uploaders"]
  end
end
