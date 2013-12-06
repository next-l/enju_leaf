class CreateEnjuTrunkInventoryInventoryCheckResults < ActiveRecord::Migration
  def change
    create_table :inventory_check_results do |t|
      t.integer :inventory_manage_id
      t.integer :status_1, :default => 0
      t.integer :status_2, :default => 0
      t.integer :status_3, :default => 0
      t.integer :status_4, :default => 0
      t.integer :status_5, :default => 0
      t.integer :status_6, :default => 0
      t.integer :status_7, :default => 0
      t.integer :status_8, :default => 0
      t.integer :status_9, :default => 0

      t.timestamps
    end
  end
end
