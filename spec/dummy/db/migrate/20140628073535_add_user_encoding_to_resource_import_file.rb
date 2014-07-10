class AddUserEncodingToResourceImportFile < ActiveRecord::Migration
  def change
    add_column :resource_import_files, :user_encoding, :string
  end
end
