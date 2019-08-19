class AddMemoToItem < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :memo, :text
  end
end
