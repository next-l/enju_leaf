class AddClosedToShelf < ActiveRecord::Migration
  def change
    add_column :shelves, :closed, :boolean, :default => false, :null => false
  end
end
