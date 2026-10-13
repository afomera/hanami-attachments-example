# frozen_string_literal: true

require "hanami/attachments/testing"

RSpec.describe "Direct uploads for VideoUploader", :db, type: :request do
  include Hanami::Attachments::Testing

  let(:uploader) { Shoebox::Uploaders::VideoUploader }
  let(:password) { "direct upload test password" }
  let(:user) { Hanami.app["repos.user_repo"].create(email_address: "uploads@example.com", password:) }

  def json = JSON.parse(last_response.body)

  it "requires a signed-in user" do
    post "/uploads/video/presign", filename: "video.mp4", size: "100"

    expect(last_response.status).to eq 303
  end

  context "when signed in" do
    before { sign_in_as(user, password:) }

    it "tells the browser where to upload" do
      post "/uploads/video/presign", filename: "video.mp4", size: "100"

      expect(last_response.status).to eq 200
      expect(json["url"]).not_to be_empty
    end

    it "rejects files over the size limit before they're sent" do
      post "/uploads/video/presign", filename: "video.mp4", size: (uploader.max_size + 1).to_s

      expect(last_response.status).to eq 422
    end

    it "rejects files of other types before they're sent" do
      post "/uploads/video/presign", filename: "program.exe", size: "100"

      expect(last_response.status).to eq 422
    end

    it "caches and checks the upload" do
      post "/uploads/video", file: Rack::Test::UploadedFile.new(fixture_path("video.mp4"))

      expect(last_response.status).to eq 200
      expect(json["file"]["storage"]).to eq "cache"
    end
  end
end
