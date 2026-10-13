# frozen_string_literal: true

require "hanami/attachments/testing"

RSpec.describe "Attachments", :db, type: :request do
  include Hanami::Attachments::Testing

  let(:password) { "a long enough password" }
  let(:user) { Hanami.app["repos.user_repo"].create(email_address: "pat@example.com", password:) }

  # Rack::Test's own upload object, so the request goes through real multipart parsing.
  def upload(name, type) = Rack::Test::UploadedFile.new(fixture_path(name), type)

  def json = JSON.parse(last_response.body)

  before { sign_in_as(user, password:) }

  describe "photos" do
    it "uploads a photo with a thumbnail and serves it inline" do
      post "/photos", photo: {title: "Beach", image: upload("image.png", "image/png")}

      expect(last_response.status).to eq 303
      photo = Hanami.app["repos.photo_repo"].for_user(user.id).first
      expect(photo.title).to eq "Beach"
      expect(photo.image.storage_key).to eq :store
      expect(photo.image.width).to eq 1
      expect(photo.image(:thumb)).to be_a(Shrine::UploadedFile)

      get photo.image_url
      expect(last_response.status).to eq 200
      expect(last_response.headers["content-type"]).to eq "image/png"
      expect(last_response.headers["content-disposition"]).to start_with "inline"
      expect(last_response.headers["x-content-type-options"]).to eq "nosniff"
    end

    it "keeps an invalid file out, and says why" do
      post "/photos", photo: {title: "Not a photo", image: upload("video.mp4", "video/mp4")}

      expect(last_response.status).to eq 422
      expect(last_response.body).to include "Image isn&#39;t an allowed type"
    end

    it "deletes a photo and its files" do
      post "/photos", photo: {image: upload("image.png", "image/png")}
      photo = Hanami.app["repos.photo_repo"].for_user(user.id).first

      delete "/photos/#{photo.id}"

      expect(last_response.status).to eq 303
      expect(photo.image.exists?).to be false
      expect(photo.image(:thumb).exists?).to be false
    end
  end

  describe "avatar" do
    it "sets, replaces and removes the avatar" do
      patch "/profile", user: {avatar: upload("avatar.png", "image/png")}
      expect(last_response.status).to eq 303
      first = Hanami.app["repos.user_repo"].get(user.id).avatar
      expect(first.storage_key).to eq :store

      patch "/profile", user: {avatar: upload("image.png", "image/png")}
      expect(first.exists?).to be false

      patch "/profile", user: {remove_avatar: "1"}
      expect(Hanami.app["repos.user_repo"].get(user.id).avatar).to be_nil
    end

    it "keeps a cached avatar across a re-rendered form" do
      cached = cached_upload(Shoebox::Uploaders::AvatarUploader, "avatar.png")

      patch "/profile", user: {cached_avatar: cached}

      expect(last_response.status).to eq 303
      expect(Hanami.app["repos.user_repo"].get(user.id).avatar.storage_key).to eq :store
    end

    it "shows the avatar in the layout" do
      patch "/profile", user: {avatar: upload("avatar.png", "image/png")}

      get "/profile/edit"

      expect(last_response.body).to include %(<img src="/storage/files/)
    end
  end

  describe "forms" do
    # Submits with the field names the page actually renders, so naming mistakes in templates or
    # attachment_field show up here.
    def field_names(html) = html.scan(/<input[^>]*name="([^"]+)"/).flatten

    it "names the photo fields so the action receives them" do
      get "/photos"
      names = field_names(last_response.body)
      expect(names).to include("photo[image]", "photo[cached_image]", "photo[title]")

      post "/photos", "photo" => {"image" => upload("image.png", "image/png"), "cached_image" => "", "title" => "From the form"}

      expect(last_response.status).to eq 303
    end

    it "wires the clip field for direct uploads" do
      get "/clips"
      html = last_response.body

      expect(html).to include %(name="clip[cached_video]" id="clip-video-cached")
      expect(html).to include %(data-direct-upload="/uploads/video/presign" data-direct-upload-field="clip-video-cached")
    end

    it "keeps a valid file in the re-rendered form, and saves it on resubmit" do
      post "/photos", photo: {title: "x" * 201, image: upload("image.png", "image/png")}

      expect(last_response.status).to eq 422
      cached = last_response.body[/id="photo-image-cached" value="([^"]+)"/, 1]
      expect(cached).not_to be_nil

      post "/photos", photo: {title: "Fixed", cached_image: CGI.unescapeHTML(cached)}

      expect(last_response.status).to eq 303
      expect(Hanami.app["repos.photo_repo"].for_user(user.id).map(&:title)).to eq ["Fixed"]
    end

    it "doesn't keep an invalid file in the re-rendered form" do
      post "/photos", photo: {image: upload("video.mp4", "video/mp4")}

      expect(last_response.status).to eq 422
      expect(last_response.body).to include %(id="photo-image-cached" value="")
    end
  end

  describe "direct uploads" do
    it "presigns to the app's own upload action for local storage" do
      post "/uploads/video/presign", filename: "clip.mp4", type: "video/mp4", size: "2000"

      expect(last_response.status).to eq 200
      expect(json).to eq("method" => "post", "url" => "/uploads/video", "fields" => {}, "headers" => {})
    end

    it "rejects files that are too big before they're sent" do
      post "/uploads/video/presign", filename: "clip.mp4", type: "video/mp4", size: (3 * 1024**3).to_s

      expect(last_response.status).to eq 422
      expect(json["errors"]).to eq ["is too large (the maximum is 2 GB)"]
    end

    it "only serves uploaders that opt in" do
      post "/uploads/avatar/presign", filename: "a.png", type: "image/png", size: "10"

      expect(last_response.status).to eq 404
    end

    it "uploads, then creates the clip from the cached data" do
      post "/uploads/video", file: upload("video.mp4", "video/mp4")
      expect(last_response.status).to eq 200
      cached = JSON.generate(json["file"])

      post "/clips", clip: {title: "", cached_video: cached}

      expect(last_response.status).to eq 303
      clip = Hanami.app["repos.clip_repo"].for_user(user.id).first
      expect(clip.title).to eq "video.mp4"
      expect(clip.video.mime_type).to eq "video/mp4"
      expect(clip.video.storage_key).to eq :store

      follow_redirect!
      expect(last_response.body).to include %(<video src="/storage/files/)
      expect(last_response.body).to include "&amp;download=1"

      get clip.video_url, {}, {"HTTP_RANGE" => "bytes=0-99"}
      expect(last_response.status).to eq 206
      expect(last_response.headers["accept-ranges"]).to eq "bytes"

      # File URLs are signed: dropping or reusing the signature doesn't work.
      get clip.video_url.sub(/\?sig=[^&]+/, "")
      expect(last_response.status).to eq 403
    end

    it "rejects a renamed file at upload time" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "evil.mp4")
        File.write(path, "<html><script>alert(1)</script></html>")

        post "/uploads/video", file: Rack::Test::UploadedFile.new(path, "video/mp4")
      end

      expect(last_response.status).to eq 422
    end

    it "requires a signed-in user" do
      delete "/session"

      post "/uploads/video/presign", filename: "clip.mp4", type: "video/mp4", size: "2000"

      expect(last_response.status).to eq 303
      expect(last_response.headers["location"]).to end_with "/session/new"
    end
  end
end
