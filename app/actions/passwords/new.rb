# frozen_string_literal: true

module Shoebox
  module Actions
    module Passwords
      class New < Shoebox::Action
        allow_unauthenticated_access

        def handle(request, response)
        end
      end
    end
  end
end
