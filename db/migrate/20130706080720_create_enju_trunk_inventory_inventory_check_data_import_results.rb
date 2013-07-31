class CreateEnjuTrunkInventoryInventoryCheckDataImportResults < ActiveRecord::Migration
  def change
    create_table :enju_trunk_inventory_inventory_check_data_import_results do |t|
      t.integer :inventory_check_data_import_file_id
      t.text :body
      t.text :error_msg

      t.timestamps
    end
  end
end
