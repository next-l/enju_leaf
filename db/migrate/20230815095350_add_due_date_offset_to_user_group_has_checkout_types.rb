class AddDueDateOffsetToUserGroupHasCheckoutTypes < ActiveRecord::Migration[6.1]
  def change
    add_column :user_group_has_checkout_types, :due_date_offset, :integer, default: 1, null: false
  end
end
