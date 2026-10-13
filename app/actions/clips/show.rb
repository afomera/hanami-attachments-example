# frozen_string_literal: true

module Shoebox
  module Actions
    module Clips
      class Show < Shoebox::Action
        include Deps["repos.clip_repo"]

        def handle(request, response)
          clip = clip_repo.find_for_user(request.params[:id], current_user(request).id)
          halt 404 unless clip

          response[:clip] = clip
        end
      end
    end
  end
end
