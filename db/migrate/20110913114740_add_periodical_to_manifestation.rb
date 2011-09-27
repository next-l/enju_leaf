class AddPeriodicalToManifestation < ActiveRecord::Migration
  def self.up
    add_column :manifestations, :periodical, :boolean, :default => false, :null => false
    add_index :manifestations, :periodical
  end

  def self.down
    remove_column :manifestations, :periodical
  end
end
