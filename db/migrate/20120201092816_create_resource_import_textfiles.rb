class CreateResourceImportTextfiles < ActiveRecord::Migration
  def self.up
    create_table :resource_import_textfiles do |t|
      t.integer :parent_id
      t.string :filename
      t.string :content_type
      t.integer :size
      t.string :file_hash
      t.integer :user_id
      t.text :note
      t.datetime :imported_at
      t.string :state
      t.string :resource_import_file_name
      t.string :resource_import_content_type
      t.integer :resource_import_file_size
      t.datetime :resource_import_updated_at

      t.timestamps
    end
    add_index :resource_import_textfiles, :parent_id
    add_index :resource_import_textfiles, :user_id
    add_index :resource_import_textfiles, :file_hash
    add_index :resource_import_textfiles, :state
  end

  def self.down
    drop_table :resource_import_textfiles
  end
end
