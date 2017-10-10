class AddClosedToShelf < ActiveRecord::Migration[5.1]
  def change
    add_column :shelves, :closed, :boolean, :default => false, :null => false
  end
end
