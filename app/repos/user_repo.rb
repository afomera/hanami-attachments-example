# frozen_string_literal: true

module Shoebox
  module Repos
    class UserRepo < Shoebox::DB::Repo
      include Deps["authentication.passwords"]

      def get(id)
        users.by_pk(id).one
      end

      def find_by_email(email_address)
        users.where(email_address: normalize_email(email_address)).one
      end

      def create(email_address:, password:)
        users.changeset(
          :create,
          email_address: normalize_email(email_address),
          password_hash: passwords.digest(password)
        ).commit
      end

      def update_password(id, password)
        users.by_pk(id).changeset(:update, password_hash: passwords.digest(password), updated_at: Time.now).commit
      end

      private

      def normalize_email(email_address)
        email_address.to_s.strip.downcase
      end
    end
  end
end
