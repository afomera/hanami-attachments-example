# frozen_string_literal: true

module Shoebox
  module Mailers
    class PasswordReset < Shoebox::Mailer
      from "noreply@example.com"
      to { |user:| user.email_address }
      subject "Reset your password"

      expose :user, :reset_url
    end
  end
end
