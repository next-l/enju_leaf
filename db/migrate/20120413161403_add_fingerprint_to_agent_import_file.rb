class AddFingerprintToAgentImportFile < ActiveRecord::Migration
  def change
    add_column :patron_import_files, :agent_import_fingerprint, :string
  end
end
