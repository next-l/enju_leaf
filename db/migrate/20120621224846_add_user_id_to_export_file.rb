class AddUserIdToExportFile < ActiveRecord::Migration
  def change
    add_column :export_files, :user_id, :integer
    add_index :export_files, :user_id
  end
end
