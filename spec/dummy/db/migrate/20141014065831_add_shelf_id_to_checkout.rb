class AddShelfIdToCheckout < ActiveRecord::Migration
  def change
    add_column :checkouts, :shelf_id, :integer
    add_index :checkouts, :shelf_id
  end
end
