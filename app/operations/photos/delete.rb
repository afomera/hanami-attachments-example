# frozen_string_literal: true

module Shoebox
  module Operations
    module Photos
      # Deletes a photo, then its files.
      class Delete < Shoebox::Operation
        include Deps["repos.photo_repo"]

        def call(photo)
          photo_repo.delete(photo.id)
          # The image and its thumbnail, once the row that pointed at them is gone.
          photo.image_attacher.destroy
          photo
        end
      end
    end
  end
end
