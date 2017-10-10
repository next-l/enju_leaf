class AddDimensionsToManifestation < ActiveRecord::Migration[5.1]
  def change
    add_column :manifestations, :dimensions, :text
  end
end
