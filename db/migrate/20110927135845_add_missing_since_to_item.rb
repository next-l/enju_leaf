class AddMissingSinceToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :missing_since, :timestamp
  end

  def self.down
    remove_column :items, :missing_since
  end
end
