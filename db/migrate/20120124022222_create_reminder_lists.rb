class CreateReminderLists < ActiveRecord::Migration
  def self.up
    create_table :reminder_lists do |t|
      t.integer :checkout_id, :null => false 
      t.integer :status, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :reminder_lists
  end
end
