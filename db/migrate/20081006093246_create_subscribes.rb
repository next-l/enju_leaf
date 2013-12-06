class CreateSubscribes < ActiveRecord::Migration
  def self.up
    create_table :subscribes do |t|
      t.integer :subscription_id, :null => false
      t.integer :work_id, :null => false
      t.datetime :start_at, :null => false
      t.datetime :end_at, :null => false

      t.timestamps
    end
    add_index :subscribes, :subscription_id
    add_index :subscribes, :work_id
  end

  def self.down
    drop_table :subscribes
  end
end
