class AddShelfIdToCheckout < ActiveRecord::Migration[4.2]
  def change
    add_column :checkouts, :shelf_id, :integer
    add_index :checkouts, :shelf_id
  end
end
