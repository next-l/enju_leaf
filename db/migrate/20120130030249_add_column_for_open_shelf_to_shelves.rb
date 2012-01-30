class AddColumnForOpenShelfToShelves < ActiveRecord::Migration
  def self.up
    add_column :shelves, :open_shelf, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :shelves, :open_shelf
  end
end
