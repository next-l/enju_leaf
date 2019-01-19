class AddExtentToManifestation < ActiveRecord::Migration[5.2]
  def change
    add_column :manifestations, :extent, :text
  end
end
