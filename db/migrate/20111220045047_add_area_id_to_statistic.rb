class AddAreaIdToStatistic < ActiveRecord::Migration
  def self.up
    add_column :statistics, :area_id, :integer, :default => 0
  end

  def self.down
    remove_column :statistics, :area_id
  end
end
