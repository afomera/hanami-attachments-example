# frozen_string_literal: true

# File storage for attachments (hanami-attachments): `cache` holds uploads that aren't attached to a
# record yet, and `store` holds attached files. STORAGE_SERVICE picks where they live.
Hanami.app.register_provider :storage do
  prepare do
    require "hanami/attachments"
  end

  start do
    register "storage.storages", Hanami::Attachments.build_storages(target["settings"], root: target.root)
  end
end
