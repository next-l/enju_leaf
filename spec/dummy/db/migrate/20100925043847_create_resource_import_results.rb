class CreateResourceImportResults < ActiveRecord::Migration[5.1]
  def change
    create_table :resource_import_results do |t|
      t.integer :resource_import_file_id
      t.uuid :manifestation_id
      t.uuid :item_id
      t.text :body

      t.timestamps
    end
    add_index :resource_import_results, :resource_import_file_id
    add_index :resource_import_results, :manifestation_id
    add_index :resource_import_results, :item_id
  end
end
