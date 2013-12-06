class RenameColumnCreateAtYyyymmToExpenses < ActiveRecord::Migration
  def self.up
    rename_column :expenses, :create_at_yyyymm, :acquired_at_ym
  end

  def self.down
    rename_column :expenses, :acquired_at_ym, :create_at_yyyymm  
  end
end
