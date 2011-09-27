class RenameSeriesStatementManifestationIdToRootManifestationId < ActiveRecord::Migration
  def self.up
    rename_column :series_statements, :manifestation_id, :root_manifestation_id
  end

  def self.down
    rename_column :series_statements, :root_manifestation_id, :manifestation_id
  end
end
