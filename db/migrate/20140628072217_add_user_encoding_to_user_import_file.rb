class AddUserEncodingToUserImportFile < ActiveRecord::Migration
  def change
    add_column :user_import_files, :user_encoding, :string
  end
end
