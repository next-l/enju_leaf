class AddCheckoutIdToCheckin < ActiveRecord::Migration[5.1]
  def change
    add_reference :checkins, :checkout, foreign_key: true
  end
end
