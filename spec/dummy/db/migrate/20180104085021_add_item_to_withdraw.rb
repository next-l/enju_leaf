class AddItemToWithdraw < ActiveRecord::Migration[5.1]
  def change
    add_reference :withdraws, :item, foreign_key: true, type: :uuid, null: false
  end
end
