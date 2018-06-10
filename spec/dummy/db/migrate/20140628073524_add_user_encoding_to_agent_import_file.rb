class AddUserEncodingToAgentImportFile < ActiveRecord::Migration[4.2]
  def change
    add_column :agent_import_files, :user_encoding, :string
  end
end
