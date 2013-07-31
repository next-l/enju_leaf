class AddCloumnInventoryManageIdToInventoryShelfBarcode < ActiveRecord::Migration
  def change
    add_column :inventory_shelf_barcodes, :inventory_manage_id, :integer
    add_column :inventory_shelf_barcodes, :inventory_shelf_group_id, :integer
  end
end
