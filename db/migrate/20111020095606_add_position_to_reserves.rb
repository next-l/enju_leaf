class AddPositionToReserves < ActiveRecord::Migration
  def self.up
    add_column :reserves, :position, :integer
  end

  def self.down
    remove_column :reserves, :position
  end
end
