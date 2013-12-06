class CreateEnjuTrunkInventoryInventoryShelfBarcodes < ActiveRecord::Migration
  def change
    create_table :inventory_shelf_barcodes do |t|
      t.string :barcode

      t.timestamps
    end
  end
end
