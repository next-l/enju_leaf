class AddCurrentCheckoutCountToUserGroupHasCheckoutType < ActiveRecord::Migration[4.2]
  def up
    add_column :user_group_has_checkout_types, :current_checkout_count, :integer
  end

  def down
    remove_column :user_group_has_checkout_types, :current_checkout_count
  end
end
