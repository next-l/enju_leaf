class CreateCheckins < ActiveRecord::Migration
  def self.up
    create_table :checkins do |t|
      t.references :item, index: true
      t.integer :librarian_id
      t.references :basket, index: true
      t.timestamps
    end
    add_index :checkins, :librarian_id
  end

  def self.down
    drop_table :checkins
  end
end
