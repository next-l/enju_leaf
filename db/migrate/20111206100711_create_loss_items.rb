class CreateLossItems < ActiveRecord::Migration
  def self.up
    create_table :loss_items do |t|
      t.integer :user_id, :null => false
      t.integer :item_id, :null => false
      t.integer :status, :default => 0
      t.text :note
      t.timestamps
    end

  end

  def self.down
    drop_table :loss_items
  end
end
