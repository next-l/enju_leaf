class AddItemToAccept < ActiveRecord::Migration[5.1]
  def change
    add_reference :accepts, :item, foreign_key: true, type: :uuid, null: false
  end
end
