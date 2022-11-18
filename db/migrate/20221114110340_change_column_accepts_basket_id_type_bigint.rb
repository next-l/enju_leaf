class ChangeColumnAcceptsBasketIdTypeBigint < ActiveRecord::Migration[6.1]
  def change
    [
      :accepts,
      :checked_items,
      :checkins,
      :checkouts,
      :withdraws
    ].each do |table|
      change_column table, :basket_id, :bigint
    end
  end
end
