class AddCheckoutIcalendarTokenToProfile < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :checkout_icalendar_token, :string
    add_index :profiles, :checkout_icalendar_token, unique: true
  end
end
