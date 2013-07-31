class AddColumnToInventoryManage < ActiveRecord::Migration
  def change
    add_column :inventory_manages, :check_started_at, :timestamp
    add_column :inventory_manages, :check_finished_at, :timestamp
  end
end
