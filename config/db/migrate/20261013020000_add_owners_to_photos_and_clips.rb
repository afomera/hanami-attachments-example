# frozen_string_literal: true

ROM::SQL.migration do
  change do
    %i[photos clips].each do |table|
      alter_table table do
        add_foreign_key :user_id, :users, null: false, on_delete: :cascade, index: true
        add_column :title, String, null: false, default: ""
      end
    end
  end
end
