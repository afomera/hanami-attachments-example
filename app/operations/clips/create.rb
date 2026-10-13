# frozen_string_literal: true

module Shoebox
  module Operations
    module Clips
      # Adds a video clip. The browser usually uploads the file directly first, so this receives the
      # cached file's data rather than the bytes.
      class Create < Shoebox::Operation
        include Deps["repos.clip_repo"]

        def call(user, params)
          video = step attach(:video, to: Structs::Clip, file: params[:video], cached: params[:cached_video])
          step require_file(video)

          title = params[:title].to_s.strip
          title = video.file.original_filename.to_s if title.empty?

          persist(video) { |values| clip_repo.create(user_id: user.id, title: title[0, 200], **values) }
        end

        private

        def require_file(attachment)
          attachment.file ? Success() : Failure[:invalid_attachment, :video, ["is missing"], attachment]
        end
      end
    end
  end
end
