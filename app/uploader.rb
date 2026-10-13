# auto_register: false
# frozen_string_literal: true

require "hanami/attachments"

module Shoebox
  # The base class for this app's uploaders (hanami-attachments). Shrine plugins added here apply to
  # every uploader: https://shrinerb.com/docs/plugins
  class Uploader < Hanami::Attachments::Uploader
    # Resolving the storages starts the :storage provider, if it hasn't started yet.
    self.storages = Hanami.app["storage.storages"]

    # How stored files are named. :pretty groups them as photo/5/image/<id>.png (derivatives
    # alongside, as <id>-thumb.png); :random uses flat random ids. Override it in any uploader.
    locations :pretty
  end
end
