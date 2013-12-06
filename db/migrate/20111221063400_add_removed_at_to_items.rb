class AddRemovedAtToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :removed_at, :timestamp
  end

  def self.down
    remove_column :items, :removed_at
  end
end
