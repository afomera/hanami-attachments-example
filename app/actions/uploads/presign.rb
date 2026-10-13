# frozen_string_literal: true

module Shoebox
  module Actions
    module Uploads
      # Checks a file the browser is about to upload directly, and tells it where to send it
      # (hanami-attachments). It inherits your base action, so your authentication applies.
      class Presign < Shoebox::Action
        def handle(request, response)
          result = Hanami::Attachments::DirectUpload.new(uploaders: "Shoebox::Uploaders").presign(
            request.params[:uploader],
            filename: request.params[:filename],
            type: request.params[:type],
            size: request.params[:size],
            upload_url: request.path.delete_suffix("/presign")
          )

          response.status = result.status
          response.format = :json
          response.body = result.json
        end
      end
    end
  end
end
