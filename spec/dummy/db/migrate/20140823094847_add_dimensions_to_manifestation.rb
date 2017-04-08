class AddDimensionsToManifestation < ActiveRecord::Migration[5.0]
  def change
    add_column :manifestations, :dimensions, :text
  end
end
