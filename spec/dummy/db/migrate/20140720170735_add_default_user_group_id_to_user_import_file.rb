class AddDefaultUserGroupIdToUserImportFile < ActiveRecord::Migration[5.2]
  def change
    add_reference :user_import_files, :default_user_group
  end
end
