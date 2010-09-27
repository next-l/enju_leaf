class AddDateIndexToResource < ActiveRecord::Migration
  def self.up
    add_index :manifestations, :created_at
    add_index :manifestations, :deleted_at
  end

  def self.down
    remove_index :manifestations, :created_at
    remove_index :manifestations, :deleted_at
  end
end
