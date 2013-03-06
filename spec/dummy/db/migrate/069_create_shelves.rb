class CreateShelves < ActiveRecord::Migration
  def change
    create_table :shelves do |t|
      t.string :name, :null => false
      t.text :display_name
      t.text :note
      t.integer :library_id, :default => 1, :null => false
      t.integer :items_count, :default => 0, :null => false
      t.integer :position
      t.timestamps
      t.datetime :deleted_at
    end
    add_index :shelves, :library_id
  end
end
