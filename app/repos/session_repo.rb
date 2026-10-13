# frozen_string_literal: true

module Shoebox
  module Repos
    class SessionRepo < Shoebox::DB::Repo
      def create(user_id:, token_digest:, ip_address: nil, user_agent: nil)
        sessions.changeset(:create, user_id:, token_digest:, ip_address:, user_agent:).commit
      end

      # Returns the session, combined with its user.
      def find_by_token_digest(token_digest)
        sessions.where(token_digest:).combine(:user).one
      end

      def delete(id)
        sessions.by_pk(id).delete
      end

      def delete_all_for_user(user_id)
        sessions.where(user_id:).delete
      end
    end
  end
end
