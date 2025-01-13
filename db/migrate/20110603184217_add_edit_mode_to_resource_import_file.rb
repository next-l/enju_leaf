class AddEditModeToResourceImportFile < ActiveRecord::Migration[4.2]
  def up
    add_column :resource_import_files, :edit_mode, :string
  end

  def down
    remove_column :resource_import_files, :edit_mode
  end
end
