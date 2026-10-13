# frozen_string_literal: true

module Shoebox
  module Operations
    # Sets a new password from a reset token, and signs the user out everywhere.
    class ResetPassword < Shoebox::Operation
      MINIMUM_LENGTH = 12

      include Deps[
        "repos.user_repo",
        "repos.session_repo",
        "authentication.password_reset_tokens"
      ]

      def call(token:, password:, password_confirmation:)
        user = step resolve_token(token)
        step validate(password, password_confirmation)

        transaction do
          user_repo.update_password(user.id, password)
          # Whoever knew the old password shouldn't stay signed in.
          session_repo.delete_all_for_user(user.id)
        end

        user
      end

      private

      def resolve_token(token)
        user = password_reset_tokens.resolve(token)
        user ? Success(user) : Failure(:invalid_token)
      end

      def validate(password, password_confirmation)
        if password.to_s.length < MINIMUM_LENGTH
          Failure[:invalid_password, "Password must be at least #{MINIMUM_LENGTH} characters."]
        elsif password != password_confirmation
          Failure[:invalid_password, "Passwords don't match."]
        else
          Success()
        end
      end
    end
  end
end
