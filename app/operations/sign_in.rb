# frozen_string_literal: true

module Shoebox
  module Operations
    # Finds the user for an email address and password.
    class SignIn < Shoebox::Operation
      include Deps["repos.user_repo", "authentication.passwords"]

      def call(email_address:, password:)
        step authenticate(email_address, password)
      end

      private

      def authenticate(email_address, password)
        user = user_repo.find_by_email(email_address)

        # Verify even when no account matched (against a dummy hash), so response times don't reveal
        # which email addresses have accounts.
        if passwords.verify(password, user&.password_hash) && user
          Success(user)
        else
          Failure(:invalid_credentials)
        end
      end
    end
  end
end
