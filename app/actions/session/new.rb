# frozen_string_literal: true

module Shoebox
  module Actions
    module Session
      class New < Shoebox::Action
        allow_unauthenticated_access

        def handle(request, response)
          response.redirect_to "/" if authenticated?(request)

          # A Turbo Frame request lands here when a frame hits an expired session. Turbo discards this
          # response and loads the page in full, so keep the flash for that second request.
          response.flash.keep if request.turbo_frame?
        end
      end
    end
  end
end
