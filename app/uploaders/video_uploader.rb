# auto_register: false
# frozen_string_literal: true

module Shoebox
  module Uploaders
    class VideoUploader < Shoebox::Uploader
      allow_types :video
      max_size 2 * 1024 * 1024 * 1024 # 2 GB
      direct_uploads

      # Add your own validations here; allow_types and max_size are checked first.
      #
      # Attacher.validate do
      #   validate_min_size 1024
      # end
    end
  end
end
