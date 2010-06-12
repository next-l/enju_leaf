class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :library_id, :default => 1, :null => false
      t.integer :event_category_id, :default => 1, :null => false
      t.string :title
      t.text :note
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :all_day, :default => false, :null => false
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :events, :library_id
    add_index :events, :event_category_id
  end

  def self.down
    drop_table :events
  end
end
