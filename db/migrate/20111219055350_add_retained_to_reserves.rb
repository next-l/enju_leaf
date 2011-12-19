class AddRetainedToReserves < ActiveRecord::Migration
  def self.up
    add_column :reserves, :retained, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :reserves, :retained
  end
end
