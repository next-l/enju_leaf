class AddDefaultUserGroupIdToUserImportFile < ActiveRecord::Migration[5.1]
  def change
    add_column :user_import_files, :default_user_group_id, :integer
  end
end
