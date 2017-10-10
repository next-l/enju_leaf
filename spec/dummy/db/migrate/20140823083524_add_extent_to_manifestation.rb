class AddExtentToManifestation < ActiveRecord::Migration[5.1]
  def change
    add_column :manifestations, :extent, :text
  end
end
