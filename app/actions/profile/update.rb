# frozen_string_literal: true

module Shoebox
  module Actions
    module Profile
      class Update < Shoebox::Action
        include Deps[update_avatar: "operations.users.update_avatar", view: "views.profile.edit"]

        def handle(request, response)
          user = current_user(request)

          case update_avatar.(user, request.params[:user] || {})
          in Success(_)
            response.flash[:notice] = "Profile updated."
            response.redirect_to routes.path(:edit_profile), status: 303
          in Failure[:invalid_attachment, :avatar, errors, attachment]
            response.flash.now[:alert] = "Avatar #{errors.join(", ")}."
            response.status = 422
            response.render(view, user:, avatar: attachment)
          end
        end
      end
    end
  end
end
