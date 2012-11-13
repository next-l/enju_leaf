class AddColumnItemToResourceImportTextresults < ActiveRecord::Migration
  def change
    #add_column :resource_import_textresults, :manifestation_id, :integer
  end

  add_index :resource_import_textresults, :manifestation_id
  add_index :resource_import_textresults, :item_id
end
