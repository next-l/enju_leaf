class CreateResourceImportFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :resource_import_files do |t|
      t.integer :parent_id
      t.string :content_type
      t.integer :size
      t.integer :user_id
      t.text :note
      t.datetime :executed_at
      t.string :resource_import_file_name
      t.string :resource_import_content_type
      t.integer :resource_import_file_size
      t.datetime :resource_import_updated_at

      t.timestamps
    end
    add_index :resource_import_files, :parent_id
    add_index :resource_import_files, :user_id
  end
end
