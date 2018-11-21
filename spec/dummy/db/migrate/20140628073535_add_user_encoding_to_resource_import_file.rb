class AddUserEncodingToResourceImportFile < ActiveRecord::Migration[5.1]
  def change
    add_column :resource_import_files, :user_encoding, :string
  end
end
