class AddDimensionsToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :dimensions, :text
  end
end
