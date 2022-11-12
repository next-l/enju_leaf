class ChangeColumnCheckoutsUserIdTypeBigint < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'ar_internal_metadata'].include?(table)

      columns = ActiveRecord::Base.connection.columns(table).map(&:name)
      change_column table, :user_id, :bigint if columns.include?('user_id')
      change_column table, :librarian_id, :bigint if columns.include?('librarian_id')
    end
  end
end
