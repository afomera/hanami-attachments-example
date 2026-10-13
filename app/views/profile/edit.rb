# frozen_string_literal: true

module Shoebox
  module Views
    module Profile
      class Edit < Shoebox::View
        expose :user
        expose :avatar, default: nil, decorate: false
      end
    end
  end
end
