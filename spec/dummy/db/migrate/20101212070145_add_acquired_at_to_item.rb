class AddAcquiredAtToItem < ActiveRecord::Migration[4.2]
  def self.up
    add_column :items, :acquired_at, :timestamp
  end

  def self.down
    remove_column :items, :acquired_at
  end
end
