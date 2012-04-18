class AddCheckoutIcalendarTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :checkout_icalendar_token, :string
  end
end
