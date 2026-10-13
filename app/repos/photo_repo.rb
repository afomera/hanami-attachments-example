# frozen_string_literal: true

module Shoebox
  module Repos
    class PhotoRepo < Shoebox::DB::Repo
      def get(id)
        photos.by_pk(id).one
      end

      def all
        photos.order { created_at.desc }.to_a
      end

      def for_user(user_id)
        photos.where(user_id:).order { id.desc }.to_a
      end

      def find_for_user(id, user_id)
        photos.where(id:, user_id:).one
      end

      def delete(id)
        photos.by_pk(id).delete
      end

      def create(attributes)
        photos.changeset(:create, attributes).commit
      end

      # Saves the image attachment's column values (hanami-attachments).
      def update_image(id, values)
        photos.by_pk(id).changeset(:update, values).commit
      end
    end
  end
end
