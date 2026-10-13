# frozen_string_literal: true

module Shoebox
  module Actions
    module Uploads
      # Receives a direct upload when files are stored locally, and caches it until the form that
      # attaches it is submitted (hanami-attachments). It inherits your base action, so your
      # authentication applies.
      class Create < Shoebox::Action
        def handle(request, response)
          result = Hanami::Attachments::DirectUpload.new(uploaders: "Shoebox::Uploaders")
            .upload(request.params[:uploader], request.params[:file])

          response.status = result.status
          response.format = :json
          response.body = result.json
        end
      end
    end
  end
end
