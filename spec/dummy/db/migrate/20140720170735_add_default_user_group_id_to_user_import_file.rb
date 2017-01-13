class AddDefaultUserGroupIdToUserImportFile < ActiveRecord::Migration
  def change
    add_column :user_import_files, :default_user_group_id, :integer
  end
end
