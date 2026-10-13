# frozen_string_literal: true

ROM::SQL.migration do
  change do
    alter_table :users do
      add_column :avatar_data, String, text: true
    end
  end
end
