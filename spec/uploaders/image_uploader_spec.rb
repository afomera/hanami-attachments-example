# frozen_string_literal: true

require "hanami/attachments/testing"
require "tmpdir"

RSpec.describe Shoebox::Uploaders::ImageUploader do
  include Hanami::Attachments::Testing
  include Hanami::Attachments::Steps

  # A stand-in for a photo row, so these tests don't need the database.
  let(:record_class) do
    uploader = described_class
    Struct.new(:image_data) { include uploader::Attachment(:image) }
  end

  it "accepts a png" do
    result = attach(:image, to: record_class.new, file: fixture_upload("image.png"))

    expect(result).to be_success
    expect(result.value!.file.storage_key).to eq :cache
  end

  it "rejects a file whose content doesn't match its extension" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "renamed.png")
      File.binwrite(path, "\x00\x01\x02\x03 not really a png")

      result = attach(:image, to: record_class.new, file: fixture_upload(path))

      expect(result).to be_failure
      expect(result.failure[0..1]).to eq [:invalid_attachment, :image]
    end
  end

  it "rejects files over the size limit" do
    allow(described_class).to receive(:max_size).and_return(1)

    result = attach(:image, to: record_class.new, file: fixture_upload("image.png"))

    expect(result.failure[2]).to include(/too large/)
  end

  it "stores a new file and deletes the one it replaces" do
    record = record_class.new(attachment_data(described_class, "image.png"))
    previous = record.image
    image = attach(:image, to: record, file: fixture_upload("image.png")).value!

    values = persist(image) { |column_values| column_values }

    stored = record_class.new(values[:image_data]).image
    expect(stored.storage_key).to eq :store
    expect(stored.exists?).to be true
    expect(previous.exists?).to be false
    expect(record_class.new(values[:image_data]).image(:thumb)).to be_a(Shrine::UploadedFile)
  end

  it "keeps the previous file when saving fails" do
    record = record_class.new(attachment_data(described_class, "image.png"))
    image = attach(:image, to: record, file: fixture_upload("image.png")).value!

    expect { persist(image) { raise "database is down" } }.to raise_error("database is down")
    expect(record.image.exists?).to be true
  end

  it "removes the file" do
    record = record_class.new(attachment_data(described_class, "image.png"))
    previous = record.image

    values = persist(detach(:image, from: record).value!) { |column_values| column_values }

    expect(values).to eq(image_data: nil)
    expect(previous.exists?).to be false
  end
end
