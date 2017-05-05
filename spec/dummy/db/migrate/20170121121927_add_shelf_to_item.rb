class AddShelfToItem < ActiveRecord::Migration[5.0]
  def change
    add_reference :items, :shelf, foreign_key: true, type: :uuid, null: false
  end
end
