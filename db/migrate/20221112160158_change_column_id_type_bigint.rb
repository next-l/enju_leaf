class ChangeColumnIdTypeBigint < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'ar_internal_metadata'].include?(table)

      change_column table, :id, :bigint
    end
  end
end
