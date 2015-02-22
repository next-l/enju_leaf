class AddDefaultShelfIdToResourceImportFile < ActiveRecord::Migration
  def change
    add_column :resource_import_files, :default_shelf_id, :integer
  end
end
