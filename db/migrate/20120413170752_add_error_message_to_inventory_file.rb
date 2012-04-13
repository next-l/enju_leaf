class AddErrorMessageToInventoryFile < ActiveRecord::Migration
  def change
    add_column :inventory_files, :error_message, :text
  end
end
