class AddLftAndRgtToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :lft, :integer
    add_column :messages, :rgt, :integer
  end
end
