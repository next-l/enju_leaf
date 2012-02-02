class AddColumnForAdapterNameToResourceImportTextfile < ActiveRecord::Migration
  def self.up
    add_column :resource_import_textfiles, :adapter_name, :string
  end

  def self.down
    remove_column :resource_import_textfiles, :adapter_name
  end
end
