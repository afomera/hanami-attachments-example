# frozen_string_literal: true

module Shoebox
  module Structs
    class Clip < Shoebox::DB::Struct
      include Uploaders::VideoUploader::Attachment(:video)
    end
  end
end
