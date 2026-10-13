# frozen_string_literal: true

require "hanami/attachments/testing"
require "tmpdir"

RSpec.describe Shoebox::Uploaders::VideoUploader do
  include Hanami::Attachments::Testing
  include Hanami::Attachments::Steps

  # A stand-in for a clip row, so these tests don't need the database.
  let(:record_class) do
    uploader = described_class
    Struct.new(:video_data) { include uploader::Attachment(:video) }
  end

  it "accepts a mp4" do
    result = attach(:video, to: record_class.new, file: fixture_upload("video.mp4"))

    expect(result).to be_success
    expect(result.value!.file.storage_key).to eq :cache
  end

  it "rejects a file whose content doesn't match its extension" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "renamed.mp4")
      File.binwrite(path, "\x00\x01\x02\x03 not really a mp4")

      result = attach(:video, to: record_class.new, file: fixture_upload(path))

      expect(result).to be_failure
      expect(result.failure[0..1]).to eq [:invalid_attachment, :video]
    end
  end

  it "rejects files over the size limit" do
    allow(described_class).to receive(:max_size).and_return(1)

    result = attach(:video, to: record_class.new, file: fixture_upload("video.mp4"))

    expect(result.failure[2]).to include(/too large/)
  end

  it "stores a new file and deletes the one it replaces" do
    record = record_class.new(attachment_data(described_class, "video.mp4"))
    previous = record.video
    video = attach(:video, to: record, file: fixture_upload("video.mp4")).value!

    values = persist(video) { |column_values| column_values }

    stored = record_class.new(values[:video_data]).video
    expect(stored.storage_key).to eq :store
    expect(stored.exists?).to be true
    expect(previous.exists?).to be false
  end

  it "keeps the previous file when saving fails" do
    record = record_class.new(attachment_data(described_class, "video.mp4"))
    video = attach(:video, to: record, file: fixture_upload("video.mp4")).value!

    expect { persist(video) { raise "database is down" } }.to raise_error("database is down")
    expect(record.video.exists?).to be true
  end

  it "removes the file" do
    record = record_class.new(attachment_data(described_class, "video.mp4"))
    previous = record.video

    values = persist(detach(:video, from: record).value!) { |column_values| column_values }

    expect(values).to eq(video_data: nil)
    expect(previous.exists?).to be false
  end
end
