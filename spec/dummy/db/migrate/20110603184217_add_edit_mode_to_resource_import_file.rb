class AddEditModeToResourceImportFile < ActiveRecord::Migration[5.1]
  def self.up
    add_column :resource_import_files, :edit_mode, :string
  end

  def self.down
    remove_column :resource_import_files, :edit_mode
  end
end
