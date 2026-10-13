# frozen_string_literal: true

module Shoebox
  module Repos
    class ClipRepo < Shoebox::DB::Repo
      def get(id)
        clips.by_pk(id).one
      end

      def all
        clips.order { created_at.desc }.to_a
      end

      def for_user(user_id)
        clips.where(user_id:).order { id.desc }.to_a
      end

      def find_for_user(id, user_id)
        clips.where(id:, user_id:).one
      end

      def delete(id)
        clips.by_pk(id).delete
      end

      def create(attributes)
        clips.changeset(:create, attributes).commit
      end

      # Saves the video attachment's column values (hanami-attachments).
      def update_video(id, values)
        clips.by_pk(id).changeset(:update, values).commit
      end
    end
  end
end
