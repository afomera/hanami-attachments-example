# frozen_string_literal: true

module Shoebox
  module Operations
    module Photos
      # Changes a photo's image: a new upload, a file kept from a re-rendered form or
      # uploaded directly by the browser, or removal (hanami-attachments).
      class UpdateImage < Shoebox::Operation
        include Deps["repos.photo_repo"]

        def call(photo, params)
          image = step attach(:image, to: photo,
            file: params[:image], cached: params[:cached_image], remove: params[:remove_image])

          persist(image) { |values| photo_repo.update_image(photo.id, values) }
        end
      end
    end
  end
end
