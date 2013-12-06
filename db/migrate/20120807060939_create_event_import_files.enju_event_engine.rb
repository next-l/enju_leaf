# This migration comes from enju_event_engine (originally 20081028093607)
class CreateEventImportFiles < ActiveRecord::Migration
  def self.up
    create_table :event_import_files do |t|
      t.integer :parent_id
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
      t.string :edit_mode

      t.timestamps
    end
    add_index :event_import_files, :parent_id
    add_index :event_import_files, :user_id
    add_index :event_import_files, :state
  end

  def self.down
    drop_table :event_import_files
  end
end
