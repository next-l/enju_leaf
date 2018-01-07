class AddDefaultUserGroupIdToUserImportFile < ActiveRecord::Migration
  def change
    add_reference :user_import_files, :default_user_group
  end
end
