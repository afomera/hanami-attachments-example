# frozen_string_literal: true

module Shoebox
  module Actions
    module Clips
      class Index < Shoebox::Action
        include Deps["repos.clip_repo"]

        def handle(request, response)
          response[:clips] = clip_repo.for_user(current_user(request).id)
        end
      end
    end
  end
end
