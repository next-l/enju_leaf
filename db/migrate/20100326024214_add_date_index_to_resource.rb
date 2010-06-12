class AddDateIndexToResource < ActiveRecord::Migration
  def self.up
    add_index :resources, :created_at
    add_index :resources, :deleted_at
  end

  def self.down
    remove_index :resources, :created_at
    remove_index :resources, :deleted_at
  end
end
