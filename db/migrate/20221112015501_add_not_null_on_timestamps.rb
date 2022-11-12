class AddNotNullOnTimestamps < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'countries', 'languages'].include?(table)

      change_column_null table, :created_at, false
      change_column table, :created_at, :datetime, precision: 6

      next if table == 'taggings'

      change_column_null table, :updated_at, false unless table == 'taggings'
      change_column table, :updated_at, :datetime, precision: 6
    end
  end
end
