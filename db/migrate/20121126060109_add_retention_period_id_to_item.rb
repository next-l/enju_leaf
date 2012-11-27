class AddRetentionPeriodIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :retention_period_id, :integer, :default => 1, :null => false
  end
end
