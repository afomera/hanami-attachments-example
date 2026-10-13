# auto_register: false
# frozen_string_literal: true

module Shoebox
  module Views
    class Context < Hanami::View::Context
      # Define your view context here. See https://hanakai.org/learn/hanami/views/context/ for details.

      # The signed-in user, as resolved by Shoebox::Authentication for this request.
      def current_user
        return unless request?

        request.env["shoebox.authentication.session"]&.user
      end

      def authenticated?
        !current_user.nil?
      end
    end
  end
end
