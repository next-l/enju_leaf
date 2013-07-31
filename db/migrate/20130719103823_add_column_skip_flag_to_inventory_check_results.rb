class AddColumnSkipFlagToInventoryCheckResults < ActiveRecord::Migration
  def change
    add_column :inventory_check_results, :skip_flag, :integer, :default => 0
    add_index :inventory_check_results, :skip_flag
    add_index :inventory_check_results, [:status_1, :status_2, :status_3, :status_4, :status_5, :status_6, :status_7, :status_8, :status_9], :name => 'inventory_check_results_index_1'
  end
end
