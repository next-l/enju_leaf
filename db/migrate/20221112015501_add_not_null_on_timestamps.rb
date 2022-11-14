class AddNotNullOnTimestamps < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'countries', 'languages', 'active_storage_blobs', 'active_storage_attachments', 'active_storage_variant_records'].include?(table)

      change_column_null table, :created_at, false
      change_column table, :created_at, :datetime, precision: 6

      next if 'taggings' == table

      change_column_null table, :updated_at, false
      change_column table, :updated_at, :datetime, precision: 6
    end
  end
end
