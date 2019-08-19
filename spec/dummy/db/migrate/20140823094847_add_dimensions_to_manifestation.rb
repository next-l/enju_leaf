class AddDimensionsToManifestation < ActiveRecord::Migration[5.2]
  def change
    add_column :manifestations, :dimensions, :text
  end
end
