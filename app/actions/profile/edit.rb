# frozen_string_literal: true

module Shoebox
  module Actions
    module Profile
      class Edit < Shoebox::Action
        def handle(request, response)
          response[:user] = current_user(request)
        end
      end
    end
  end
end
