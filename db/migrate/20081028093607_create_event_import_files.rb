class CreateEventImportFiles < ActiveRecord::Migration
  def change
    create_table :event_import_files do |t|
      t.integer :parent_id
      t.string :filename
      t.string :content_type
      t.integer :size
      t.integer :user_id
      t.text :note
      t.datetime :imported_at
      t.string :state
      t.string :event_import_file_name
      t.string :event_import_content_type
      t.integer :event_import_file_size
      t.datetime :event_import_updated_at

      t.timestamps
    end
    add_index :event_import_files, :parent_id
    add_index :event_import_files, :user_id
    add_index :event_import_files, :state
  end
end
