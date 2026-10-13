# frozen_string_literal: true

module Shoebox
  module Actions
    module Clips
      class Create < Shoebox::Action
        include Deps["repos.clip_repo", create_clip: "operations.clips.create", view: "views.clips.index"]

        def handle(request, response)
          user = current_user(request)

          case create_clip.(user, request.params[:clip] || {})
          in Success(clip)
            response.flash[:notice] = "Clip added."
            response.redirect_to routes.path(:clip, id: clip.id), status: 303
          in Failure[:invalid_attachment, :video, errors, attachment]
            response.flash.now[:alert] = "Video #{errors.join(", ")}."
            response.status = 422
            response.render(view, clips: clip_repo.for_user(user.id), video: attachment)
          end
        end
      end
    end
  end
end
