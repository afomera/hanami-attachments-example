# frozen_string_literal: true

module Shoebox
  module Actions
    module Photos
      class Create < Shoebox::Action
        include Deps["repos.photo_repo", create_photo: "operations.photos.create", view: "views.photos.index"]

        def handle(request, response)
          user = current_user(request)

          case create_photo.(user, request.params[:photo] || {})
          in Success(_)
            response.flash[:notice] = "Photo added."
            response.redirect_to routes.path(:photos), status: 303
          in Failure[:invalid_attachment, :image, errors, attachment]
            response.flash.now[:alert] = "Image #{errors.join(", ")}."
            response.status = 422
            response.render(view, photos: photo_repo.for_user(user.id), image: attachment)
          in Failure[:invalid, field, errors, attachment]
            response.flash.now[:alert] = "#{field.to_s.capitalize} #{errors.join(", ")}."
            response.status = 422
            response.render(view, photos: photo_repo.for_user(user.id), image: attachment)
          end
        end
      end
    end
  end
end
