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
