class AddCirculationStatusIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :circulation_status_id, :integer, :default => 5, :null => false
    add_column :items, :checkout_type_id, :integer, :default => 1, :null => false
    add_index :items, :circulation_status_id
    add_index :items, :checkout_type_id
  end
end
