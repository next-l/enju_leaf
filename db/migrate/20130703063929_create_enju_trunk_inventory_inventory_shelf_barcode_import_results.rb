class CreateEnjuTrunkInventoryInventoryShelfBarcodeImportResults < ActiveRecord::Migration
  def change
    create_table :inventory_shelf_barcode_import_results do |t|
      t.integer :inventory_shelf_barcode_import_file_id
      t.integer :user_id
      t.text :body
      t.text :error_msg

      t.timestamps
    end
  end
end
