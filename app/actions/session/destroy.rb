# frozen_string_literal: true

module Shoebox
  module Actions
    module Session
      class Destroy < Shoebox::Action
        def handle(request, response)
          terminate_session(request)
          response.flash[:notice] = "Signed out."
          response.redirect_to routes.path(:new_session), status: 303
        end
      end
    end
  end
end
