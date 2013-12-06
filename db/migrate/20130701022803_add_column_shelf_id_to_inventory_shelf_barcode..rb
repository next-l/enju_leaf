class AddColumnShelfIdToInventoryShelfBarcode < ActiveRecord::Migration
  def change
    add_column :inventory_shelf_barcodes, :shelf_id, :integer
  end

end
