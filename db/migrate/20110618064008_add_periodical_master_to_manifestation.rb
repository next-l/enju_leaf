class AddPeriodicalMasterToManifestation < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :periodical_master, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :manifestations, :periodical_master
  end
end
