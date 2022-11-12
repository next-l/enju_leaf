class ChangeColumnCheckoutsAgentIdTypeBigint < ActiveRecord::Migration[6.1]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      next if ['schema_migrations', 'ar_internal_metadata'].include?(table)
      next unless ActiveRecord::Base.connection.columns(table).map(&:name).include?('agent_id')

      change_column table, :agent_id, :bigint
    end
  end
end
