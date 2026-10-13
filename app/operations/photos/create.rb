# frozen_string_literal: true

module Shoebox
  module Operations
    module Photos
      # Adds a photo to a user's shoebox.
      class Create < Shoebox::Operation
        include Deps["repos.photo_repo"]

        def call(user, params)
          # Attach first: if another field is invalid, the failure carries the cached file, so the
          # re-rendered form keeps it.
          image = step attach(:image, to: Structs::Photo, file: params[:image], cached: params[:cached_image])
          step require_file(image)
          title = step validate_title(params[:title], image)

          persist(image) { |values| photo_repo.create(user_id: user.id, title:, **values) }
        end

        private

        def require_file(attachment)
          attachment.file ? Success() : Failure[:invalid_attachment, :image, ["is missing"], attachment]
        end

        def validate_title(title, attachment)
          title = title.to_s.strip
          title.length <= 200 ? Success(title) : Failure[:invalid, :title, ["is too long"], attachment]
        end
      end
    end
  end
end
