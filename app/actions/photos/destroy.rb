# frozen_string_literal: true

module Shoebox
  module Actions
    module Photos
      class Destroy < Shoebox::Action
        include Deps["repos.photo_repo", delete_photo: "operations.photos.delete"]

        def handle(request, response)
          photo = photo_repo.find_for_user(request.params[:id], current_user(request).id)
          halt 404 unless photo

          delete_photo.(photo)
          response.flash[:notice] = "Photo deleted."
          response.redirect_to routes.path(:photos), status: 303
        end
      end
    end
  end
end
