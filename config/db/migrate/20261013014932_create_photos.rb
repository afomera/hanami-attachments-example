# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :photos do
      primary_key :id
      column :image_data, String, text: true
      column :created_at, DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
