class AddColumnForCreateYyyymmToExpense < ActiveRecord::Migration
  def self.up
    add_column :expenses, :create_at_yyyymm, :integer
    add_index :expenses, :create_at_yyyymm
  end

  def self.down
    remove_column :expenses, :create_at_yyyymm
    remove_index :expenses, :create_at_yyyymm
  end
end
