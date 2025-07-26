class AddUniqueIndexToCheckedItemsOnBasketIdAndItemId < ActiveRecord::Migration[6.1]
  def change
    remove_index :checked_items, :item_id
    add_index :checked_items, [:item_id, :basket_id], unique: true

    remove_index :checkins, :item_id
    add_index :checkins, [:item_id, :basket_id], unique: true

    remove_index :checkouts, [:item_id, :basket_id]
    add_index :checkouts, [:item_id, :basket_id, :user_id], unique: true
  end
end
