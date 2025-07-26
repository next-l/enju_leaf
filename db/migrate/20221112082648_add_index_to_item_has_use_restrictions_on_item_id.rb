class AddIndexToItemHasUseRestrictionsOnItemId < ActiveRecord::Migration[6.1]
  def change
    remove_index :item_has_use_restrictions, :item_id
    add_index :item_has_use_restrictions, [:item_id, :use_restriction_id], unique: true, name: 'index_item_has_use_restrictions_on_item_and_use_restriction'
  end
end
