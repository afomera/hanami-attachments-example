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
