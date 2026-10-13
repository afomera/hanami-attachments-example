# frozen_string_literal: true

module Shoebox
  module Views
    module Photos
      class Index < Shoebox::View
        expose :photos
        # The attachment from a failed upload, so the form keeps the chosen file.
        expose :image, default: nil, decorate: false
      end
    end
  end
end
