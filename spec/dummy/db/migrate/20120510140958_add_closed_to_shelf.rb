class AddClosedToShelf < ActiveRecord::Migration[4.2]
  def change
    add_column :shelves, :closed, :boolean, default: false, null: false
  end
end
