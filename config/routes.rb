# frozen_string_literal: true

module Shoebox
  class Routes < Hanami::Routes
    # Add your routes here. See https://hanakai.org/learn/hanami/routing/ for details.

    resource :session, only: %i[new create destroy]
    resources :passwords, only: %i[new create edit update]

    # File attachments: local file downloads and direct uploads (hanami-attachments).
    mount Hanami::Attachments::DownloadEndpoint.new, at: "/storage/files"
    post "/uploads/:uploader/presign", to: "uploads.presign", as: :upload_presign
    post "/uploads/:uploader", to: "uploads.create", as: :upload
  end
end
