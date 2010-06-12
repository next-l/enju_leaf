class CreateImportedObjects < ActiveRecord::Migration
  def self.up
    create_table :imported_objects do |t|
      t.integer :imported_file_id
      t.string :imported_file_type
      t.integer :importable_id
      t.string :importable_type
      t.string :state
      t.integer :line_number

      t.timestamps
    end
    add_index :imported_objects, [:imported_file_id, :imported_file_type], :name => "index_imported_objects_on_imported_file_id_and_type"
    add_index :imported_objects, [:importable_id, :importable_type], :name => "index_imported_objects_on_importable_id_and_type"
  end

  def self.down
    drop_table :imported_objects
  end
end
