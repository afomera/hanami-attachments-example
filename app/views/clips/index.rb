# frozen_string_literal: true

module Shoebox
  module Views
    module Clips
      class Index < Shoebox::View
        expose :clips
        expose :video, default: nil, decorate: false
      end
    end
  end
end
