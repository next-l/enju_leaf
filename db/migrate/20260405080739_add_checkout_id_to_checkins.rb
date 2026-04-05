class AddCheckoutIdToCheckins < ActiveRecord::Migration[7.2]
  def change
    add_reference :checkins, :checkout

    Checkout.joins(:checkin).find_each do |i|
      i.checkin.update_column(:checkout_id, i.id)
    end

    change_column_null :checkins, :checkout_id, false
    remove_column :checkouts, :checkin_id, :bigint
  end
end
