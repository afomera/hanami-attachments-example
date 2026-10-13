# frozen_string_literal: true

module Shoebox
  module Structs
    class Photo < Shoebox::DB::Struct
      include Uploaders::ImageUploader::Attachment(:image)
    end
  end
end
