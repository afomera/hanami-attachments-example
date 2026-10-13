# auto_register: false
# frozen_string_literal: true

require "image_processing/vips"

module Shoebox
  module Uploaders
    class AvatarUploader < Shoebox::Uploader
      allow_types :images
      max_size 10 * 1024 * 1024 # 10 MB

      plugin :store_dimensions, analyzer: :ruby_vips, auto_extraction: false
      plugin :add_metadata
      plugin :derivatives, create_on_promote: true

      # Width and height, read only from files whose content really is an image, so libvips never
      # decodes arbitrary uploads.
      add_metadata do |io, metadata:, **|
        next {} unless metadata["mime_type"].to_s.start_with?("image/")

        width, height = self.class.extract_dimensions(io)
        {"width" => width, "height" => height}
      end

      Attacher.derivatives do |original|
        vips = ImageProcessing::Vips.source(original)

        {thumb: vips.resize_to_limit!(300, 300)}
      end

      # Add your own validations here; allow_types and max_size are checked first.
      #
      # Attacher.validate do
      #   validate_min_size 1024
      # end
    end
  end
end
