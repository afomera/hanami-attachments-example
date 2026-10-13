# frozen_string_literal: true

ROM::SQL.migration do
  change do
    create_table :sessions do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade, index: true
      column :token_digest, String, null: false
      column :ip_address, String
      column :user_agent, String
      column :created_at, DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP

      index :token_digest, unique: true
    end
  end
end
