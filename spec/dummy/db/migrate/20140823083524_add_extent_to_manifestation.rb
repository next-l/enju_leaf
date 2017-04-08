class AddExtentToManifestation < ActiveRecord::Migration[5.0]
  def change
    add_column :manifestations, :extent, :text
  end
end
