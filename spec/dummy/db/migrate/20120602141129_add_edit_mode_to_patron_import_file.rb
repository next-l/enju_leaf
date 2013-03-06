class AddEditModeToPatronImportFile < ActiveRecord::Migration
  def change
    add_column :patron_import_files, :edit_mode, :string
  end
end
