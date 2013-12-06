class AddColumnItemIdentifierToInventoryCheckResults < ActiveRecord::Migration
  def change
    add_column :inventory_check_results, :item_identifier, :string
    add_index :inventory_check_results, :item_identifier
  end
end
