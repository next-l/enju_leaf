class RenameSeriesStatementRootManifestationIdToManifestationId < ActiveRecord::Migration
  def up
    remove_index :series_statements, :series_statement_identifier
    rename_column :series_statements, :root_manifestation_id, :manifestation_id
    add_index :series_statements, :series_statement_identifier
  end

  def down
    remove_index :series_statements, :series_statement_identifier
    rename_column :series_statements, :manifestation_id, :root_manifestation_id
    add_index :series_statements, :series_statement_identifier
  end
end
