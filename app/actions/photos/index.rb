# frozen_string_literal: true

module Shoebox
  module Actions
    module Photos
      class Index < Shoebox::Action
        include Deps["repos.photo_repo"]

        def handle(request, response)
          response[:photos] = photo_repo.for_user(current_user(request).id)
        end
      end
    end
  end
end
