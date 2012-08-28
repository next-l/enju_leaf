class AddEditMode < ActiveRecord::Migration
  def up
    add_column :resource_import_files, :edit_mode, :string
    add_column :patron_import_files, :edit_mode, :string
  end

  def down
    remove_column :patron_import_files, :edit_mode
    remove_column :resource_import_files, :edit_mode
  end
end
