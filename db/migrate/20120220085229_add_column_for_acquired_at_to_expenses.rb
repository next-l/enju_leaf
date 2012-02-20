class AddColumnForAcquiredAtToExpenses < ActiveRecord::Migration
  def self.up
    add_column :expenses, :acquired_at, :timestamp
  end

  def self.down
    remove_column :expenses, :acquired_at
  end
end
