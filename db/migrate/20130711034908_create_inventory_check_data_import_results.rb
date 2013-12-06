class CreateInventoryCheckDataImportResults < ActiveRecord::Migration
  def change
    create_table :inventory_check_data_import_results do |t|
      t.integer :inventory_check_data_import_file_id
      t.integer :user_id
      t.text :body
      t.text :error_msg

      t.timestamps
    end
  end
end
