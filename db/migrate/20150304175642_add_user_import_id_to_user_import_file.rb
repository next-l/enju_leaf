class AddUserImportIdToUserImportFile < ActiveRecord::Migration
  def change
    add_column :user_import_files, :user_import_id, :string
    add_column :user_import_files, :user_import_size, :integer
    add_index :user_import_files, :user_import_id
  end
end
