class ChangeColumnCheckoutsItemIdTypeBigint < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'ar_internal_metadata'].include?(table)
      next unless ActiveRecord::Base.connection.columns(table).map(&:name).include?('item_id')

      change_column table, :item_id, :bigint
    end
  end
end
