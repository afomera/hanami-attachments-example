# frozen_string_literal: true

require "hanami/attachments/testing"
require "tmpdir"

RSpec.describe Shoebox::Uploaders::AvatarUploader do
  include Hanami::Attachments::Testing
  include Hanami::Attachments::Steps

  # A stand-in for a user row, so these tests don't need the database.
  let(:record_class) do
    uploader = described_class
    Struct.new(:avatar_data) { include uploader::Attachment(:avatar) }
  end

  it "accepts a png" do
    result = attach(:avatar, to: record_class.new, file: fixture_upload("avatar.png"))

    expect(result).to be_success
    expect(result.value!.file.storage_key).to eq :cache
  end

  it "rejects a file whose content doesn't match its extension" do
    Dir.mktmpdir do |dir|
      path = File.join(dir, "renamed.png")
      File.binwrite(path, "\x00\x01\x02\x03 not really a png")

      result = attach(:avatar, to: record_class.new, file: fixture_upload(path))

      expect(result).to be_failure
      expect(result.failure[0..1]).to eq [:invalid_attachment, :avatar]
    end
  end

  it "rejects files over the size limit" do
    allow(described_class).to receive(:max_size).and_return(1)

    result = attach(:avatar, to: record_class.new, file: fixture_upload("avatar.png"))

    expect(result.failure[2]).to include(/too large/)
  end

  it "stores a new file and deletes the one it replaces" do
    record = record_class.new(attachment_data(described_class, "avatar.png"))
    previous = record.avatar
    avatar = attach(:avatar, to: record, file: fixture_upload("avatar.png")).value!

    values = persist(avatar) { |column_values| column_values }

    stored = record_class.new(values[:avatar_data]).avatar
    expect(stored.storage_key).to eq :store
    expect(stored.exists?).to be true
    expect(previous.exists?).to be false
    expect(record_class.new(values[:avatar_data]).avatar(:thumb)).to be_a(Shrine::UploadedFile)
  end

  it "keeps the previous file when saving fails" do
    record = record_class.new(attachment_data(described_class, "avatar.png"))
    avatar = attach(:avatar, to: record, file: fixture_upload("avatar.png")).value!

    expect { persist(avatar) { raise "database is down" } }.to raise_error("database is down")
    expect(record.avatar.exists?).to be true
  end

  it "removes the file" do
    record = record_class.new(attachment_data(described_class, "avatar.png"))
    previous = record.avatar

    values = persist(detach(:avatar, from: record).value!) { |column_values| column_values }

    expect(values).to eq(avatar_data: nil)
    expect(previous.exists?).to be false
  end
end
