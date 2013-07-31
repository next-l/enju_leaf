class AddColumnSkipFlagToCheckData < ActiveRecord::Migration
  def change
    add_column :inventory_check_data, :skip_flag, :integer, :null => false, :default => 0
    add_index :inventory_check_data, :skip_flag
  end
end
