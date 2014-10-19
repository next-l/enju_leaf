class AddExtentToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :extent, :text
  end
end
