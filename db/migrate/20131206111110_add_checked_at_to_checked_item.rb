class AddCheckedAtToCheckedItem < ActiveRecord::Migration
  def change
    add_column :checked_items, :checked_at, :datetime
  end
end
