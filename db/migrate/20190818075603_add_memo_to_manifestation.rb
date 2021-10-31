class AddMemoToManifestation < ActiveRecord::Migration[5.2]
  def change
    add_column :manifestations, :memo, :text
  end
end
