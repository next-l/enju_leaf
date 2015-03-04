class AddUserExportIdToUserExportFile < ActiveRecord::Migration
  def change
    add_column :user_export_files, :user_export_id, :string
    add_column :user_export_files, :user_export_size, :integer
    add_index :user_export_files, :user_export_id
  end
end
