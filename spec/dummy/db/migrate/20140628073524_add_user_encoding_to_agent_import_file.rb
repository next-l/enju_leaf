class AddUserEncodingToAgentImportFile < ActiveRecord::Migration
  def change
    add_column :agent_import_files, :user_encoding, :string
  end
end
