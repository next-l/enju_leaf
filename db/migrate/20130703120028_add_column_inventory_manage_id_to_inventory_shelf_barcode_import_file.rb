class AddColumnInventoryManageIdToInventoryShelfBarcodeImportFile < ActiveRecord::Migration
  def change
    add_column :inventory_shelf_barcode_import_files, :inventory_manage_id, :integer
  end
end
