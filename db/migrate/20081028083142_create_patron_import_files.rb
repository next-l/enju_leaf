class CreatePatronImportFiles < ActiveRecord::Migration
  def self.up
    create_table :patron_import_files do |t|
      t.integer :parent_id
      t.string :filename
      t.string :content_type
      t.integer :size
      t.string :file_hash
      t.integer :user_id
      t.text :note
      t.datetime :imported_at
      t.string :state
      t.string :patron_import_file_name
      t.string :patron_import_content_type
      t.integer :patron_import_file_size
      t.datetime :patron_import_updated_at

      t.timestamps
    end
    add_index :patron_import_files, :parent_id
    add_index :patron_import_files, :user_id
    add_index :patron_import_files, :file_hash
    add_index :patron_import_files, :state
  end

  def self.down
    drop_table :patron_import_files
  end
end
