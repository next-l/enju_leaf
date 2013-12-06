class AddCheckedAtToCheckout < ActiveRecord::Migration
  def change
    add_column :checkouts, :checked_at, :datetime
  end
end
