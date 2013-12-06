class RenameColumnOpenShelf < ActiveRecord::Migration
  def self.up
    rename_column :shelves, :open_shelf, :open_access
  end

  def self.down
    rename_column :shelves, :open_access, :open_shelf
  end
end
