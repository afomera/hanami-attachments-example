# frozen_string_literal: true

module Shoebox
  module Operations
    module Clips
      # Changes a clip's video: a new upload, a file kept from a re-rendered form or
      # uploaded directly by the browser, or removal (hanami-attachments).
      class UpdateVideo < Shoebox::Operation
        include Deps["repos.clip_repo"]

        def call(clip, params)
          video = step attach(:video, to: clip,
            file: params[:video], cached: params[:cached_video], remove: params[:remove_video])

          persist(video) { |values| clip_repo.update_video(clip.id, values) }
        end
      end
    end
  end
end
