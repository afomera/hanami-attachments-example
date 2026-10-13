# frozen_string_literal: true

module Shoebox
  module Operations
    # Emails a password reset link, if the email address belongs to an account.
    class RequestPasswordReset < Shoebox::Operation
      include Deps[
        "repos.user_repo",
        "authentication.password_reset_tokens",
        "routes",
        "logger",
        password_reset_mailer: "mailers.password_reset"
      ]

      def call(email_address:)
        user = step find_user(email_address)

        # Build the link from the configured base URL, never a request's Host header, so a forged Host
        # can't point the emailed link at another site.
        reset_url = routes.url(:edit_password, id: password_reset_tokens.generate(user)).to_s
        password_reset_mailer.deliver(user:, reset_url:)

        # Without SMTP configured, development mail is held in memory. Log the link so you can use it.
        logger.info("Password reset link for #{user.email_address}: #{reset_url}") if Hanami.env?(:development)

        user
      end

      private

      def find_user(email_address)
        user = user_repo.find_by_email(email_address)
        user ? Success(user) : Failure(:unknown_email)
      end
    end
  end
end
