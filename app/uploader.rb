# auto_register: false
# frozen_string_literal: true

require "hanami/attachments"

module Shoebox
  # The base class for this app's uploaders (hanami-attachments). Shrine plugins added here apply to
  # every uploader: https://shrinerb.com/docs/plugins
  class Uploader < Hanami::Attachments::Uploader
    # Resolving the storages starts the :storage provider, if it hasn't started yet.
    self.storages = Hanami.app["storage.storages"]
  end
end
