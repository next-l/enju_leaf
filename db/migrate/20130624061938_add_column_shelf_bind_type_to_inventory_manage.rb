class AddColumnShelfBindTypeToInventoryManage < ActiveRecord::Migration
  def change
    add_column :inventory_manages, :bind_type, :string, :default => "0", :null => false
  end
end
