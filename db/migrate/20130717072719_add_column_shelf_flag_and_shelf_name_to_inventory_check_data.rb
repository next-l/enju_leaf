class AddColumnShelfFlagAndShelfNameToInventoryCheckData < ActiveRecord::Migration
  def change
    add_column :inventory_check_data, :shelf_flag, :integer, default: 0
    add_column :inventory_check_data, :shelf_name, :string
  end
end
